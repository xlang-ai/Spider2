{{
    config(
        materialized='incremental',
        partition_by = {'field': 'date_day', 'data_type': 'date'} if target.type not in ['spark','databricks'] else ['date_day'],
        unique_key='lead_day_id',
        incremental_strategy='delete+insert' if target.type in ['duckdb', 'bigquery'] else 'delete+insert',
        file_format='delta'
    ) 
}}

{% if execute -%}
    {% set results = run_query('select rest_name_xf from ' ~ var('lead_describe')) %}
    {% set results_list = results.columns[0].values() %}
{% endif -%}

with change_data as (

    select *
    from {{ var('change_data_value') }}
    {% if is_incremental() %}
    where cast({{ dbt.dateadd('day', -1, 'activity_timestamp') }} as date) >= (select max(date_day) from {{ this }})
    {% endif %}

), lead_describe as (

    select *
    from {{ var('lead_describe') }}

), joined as ( 

    -- Join the column names from the describe table onto the change data table

    select 
        change_data.*,
        lead_describe.rest_name_xf as primary_attribute_column
    from change_data
    left join lead_describe
        on change_data.primary_attribute_value_id = lead_describe.lead_describe_id

), pivots as (

    -- For each column that is in both the lead_history_columns variable and the restname of the lead_describe table,
    -- find whether a change occurred for a given column on a given day for a given lead. 
    -- This will feed the daily slowly changing dimension model.

    select 
        lead_id,
        cast({{ dbt.dateadd('day', -1, 'activity_timestamp') }} as date) as date_day

        {% for col in results_list if col|lower|replace("__c","_c") in var('lead_history_columns') %}
        {% set col_xf = col|lower|replace("__c","_c") %}
        , cast( max(case when lower(primary_attribute_column) = '{{ col|lower }}' then 1 else 0 end) as boolean) as {{ col_xf }}
        {% endfor %}
    
    from joined
    where cast(activity_timestamp as date) < current_date
    group by 1,2

), surrogate_key as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['lead_id','date_day'])}} as lead_day_id
    from pivots

)

select *
from surrogate_key
