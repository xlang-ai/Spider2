{{
    config(
        materialized='table' if jira.jira_is_databricks_sql_warehouse() else 'incremental',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        cluster_by = ['date_day', 'issue_id'],
        unique_key='issue_day_id',
        incremental_strategy = 'insert_overwrite' if target.type in ('bigquery', 'databricks', 'spark') else 'delete+insert',
        file_format='delta' if jira.jira_is_databricks_sql_warehouse() else 'parquet'
    )
}}

-- grab column names that were pivoted out
{%- set pivot_data_columns = adapter.get_columns_in_relation(ref('int_jira__field_history_scd')) -%}

{% if is_incremental() %}
-- set max date_day with lookback as a variable for multiple uses
{% set max_date_day = jira.jira_lookback(from_date='max(date_day)', datepart='day', interval=var('lookback_window', 3)) %}
{% endif %}

-- in intermediate/field_history/
with pivoted_daily_history as (

    select * 
    from {{ ref('int_jira__field_history_scd') }}

    {% if is_incremental() %}
    where valid_starting_on >= {{ max_date_day }}

-- If no issue fields have been updated since the last incremental run, the pivoted_daily_history CTE will return no record/rows.
-- When this is the case, we need to grab the most recent day's records from the previously built table so that we can persist 
-- those values into the future.

), most_recent_data as ( 
    select 
        *
    from {{ this }}
    where date_day >= {{ max_date_day }}

{% endif %}

), field_option as (
    
    select *
    from {{ var('field_option') }}
),

statuses as (
    
    select *
    from {{ var('status') }}
),

issue_types as (
    
    select *
    from {{ var('issue_type') }}
),

{% if var('jira_using_components', True) %}
components as (

    select * 
    from {{ var('component') }}
),
{% endif %}

-- in intermediate/field_history/
calendar as (

    select *
    from {{ ref('int_jira__issue_calendar_spine') }}

    {% if is_incremental() %}
    where date_day >= {{ max_date_day }}
    {% endif %}
),

joined as (

    select
        calendar.date_day,
        calendar.issue_id

        {% if is_incremental() %}    
            {% for col in pivot_data_columns %}
                {% if col.name|lower == 'components' and var('jira_using_components', True) %}
                , coalesce(pivoted_daily_history.components, most_recent_data.components) as components

                {% elif col.name|lower not in ['issue_day_id', 'issue_id', 'valid_starting_on', 'components'] %} 
                , coalesce(pivoted_daily_history.{{ col.name }}, most_recent_data.{{ col.name }}) as {{ col.name }}

                {% endif %}
            {% endfor %} 

        {% else %}
            {% for col in pivot_data_columns %}
                {% if col.name|lower == 'components' and var('jira_using_components', True) %}
                , pivoted_daily_history.components   

                {% elif col.name|lower not in ['issue_day_id', 'issue_id', 'valid_starting_on', 'components'] %} 
                , pivoted_daily_history.{{ col.name }}

                {% endif %}
            {% endfor %} 
        {% endif %}
    
    from calendar
    left join pivoted_daily_history 
        on calendar.issue_id = pivoted_daily_history.issue_id
        and calendar.date_day = pivoted_daily_history.valid_starting_on
    
    {% if is_incremental() %}
    left join most_recent_data
        on calendar.issue_id = most_recent_data.issue_id
        and calendar.date_day = most_recent_data.date_day
    {% endif %}
),

set_values as (
    select
        date_day,
        issue_id,
        joined.status_id,
        sum( case when joined.status_id is null then 0 else 1 end) over ( partition by issue_id
            order by date_day rows unbounded preceding) as status_id_field_partition

        -- list of exception columns
        {% set exception_cols = ['issue_id', 'issue_day_id', 'valid_starting_on', 'status', 'status_id', 'components', 'issue_type'] %}

        {% for col in pivot_data_columns %}
            {% if col.name|lower == 'components' and var('jira_using_components', True) %}
            , coalesce(components.component_name, joined.components) as components
            , sum(case when joined.components is null then 0 else 1 end) over (partition by issue_id order by date_day rows unbounded preceding) as component_field_partition

            {% elif col.name|lower == 'issue_type' %}
            , coalesce(issue_types.issue_type_name, joined.issue_type) as issue_type
            , sum(case when joined.issue_type is null then 0 else 1 end) over (partition by issue_id order by date_day rows unbounded preceding) as issue_type_field_partition

            {% elif col.name|lower not in exception_cols %}
            , coalesce(field_option_{{ col.name }}.field_option_name, joined.{{ col.name }}) as {{ col.name }}
            -- create a batch/partition once a new value is provided
            , sum( case when joined.{{ col.name }} is null then 0 else 1 end) over ( partition by issue_id
                order by date_day rows unbounded preceding) as {{ col.name }}_field_partition

            {% endif %}
        {% endfor %}

    from joined

    {% for col in pivot_data_columns %}
        {% if col.name|lower == 'components' and var('jira_using_components', True) %}
        left join components   
            on cast(components.component_id as {{ dbt.type_string() }}) = joined.components
        
        {% elif col.name|lower == 'issue_type' %}
        left join issue_types   
            on cast(issue_types.issue_type_id as {{ dbt.type_string() }}) = joined.issue_type

        {% elif col.name|lower not in exception_cols %}
        left join field_option as field_option_{{ col.name }}
            on cast(field_option_{{ col.name }}.field_id as {{ dbt.type_string() }}) = joined.{{ col.name }}

        {% endif %}
    {% endfor %}
),

fill_values as (

    select  
        date_day,
        issue_id,
        first_value( status_id ) over (
            partition by issue_id, status_id_field_partition 
            order by date_day asc rows between unbounded preceding and current row) as status_id

        {% for col in pivot_data_columns %}
            {% if col.name|lower == 'components' and var('jira_using_components', True) %}
            , first_value(components) over (
                partition by issue_id, component_field_partition 
                order by date_day asc rows between unbounded preceding and current row) as components

            {% elif col.name|lower not in ['issue_id', 'issue_day_id', 'valid_starting_on', 'status', 'status_id', 'components'] %}
            -- grab the value that started this batch/partition
            , first_value( {{ col.name }} ) over (
                partition by issue_id, {{ col.name }}_field_partition 
                order by date_day asc rows between unbounded preceding and current row) as {{ col.name }}

            {% endif %}
        {% endfor %}

    from set_values
),

fix_null_values as (

    select  
        date_day,
        issue_id

        {% for col in pivot_data_columns %}
            {% if col.name|lower == 'components' and var('jira_using_components', True) %}
            , case when components = 'is_null' then null else components end as components

            {% elif col.name|lower not in ['issue_id','issue_day_id','valid_starting_on', 'status', 'components'] %}
            -- we de-nulled the true null values earlier in order to differentiate them from nulls that just needed to be backfilled
            , case when {{ col.name }} = 'is_null' then null else {{ col.name }} end as {{ col.name }}

            {% endif %}
        {% endfor %}

    from fill_values

),

surrogate_key as (

    select
        fix_null_values.date_day,
        fix_null_values.issue_id,
        statuses.status_name as status

        {% for col in pivot_data_columns %}
            {% if col.name|lower == 'components' and var('jira_using_components', True) %}
            , fix_null_values.components as components

            {% elif col.name|lower not in ['issue_id','issue_day_id','valid_starting_on', 'status', 'components'] %} 
            , fix_null_values.{{ col.name }} as {{ col.name }}

            {% endif %}
        {% endfor %}

        , {{ dbt_utils.generate_surrogate_key(['date_day','issue_id']) }} as issue_day_id

    from fix_null_values

    left join statuses
        on cast(statuses.status_id as {{ dbt.type_string() }}) = fix_null_values.status_id
)

select *
from surrogate_key