{{
    config(
        materialized='incremental',
        partition_by = {'field': 'date_day', 'data_type': 'date'} if target.type not in ['spark','databricks'] else ['date_day'],
        unique_key='lead_history_id',
        incremental_strategy='delete+insert' if target.type not in ['postgres', 'redshift'] else 'delete+insert',
        file_format='delta'
        ) 
}}

{%- set change_data_columns = adapter.get_columns_in_relation(ref('marketo__change_data_scd')) -%}
{% set filtered_change_data_columns = [] %}
{% for col in change_data_columns if col.name|lower not in ['lead_id','valid_to','lead_day_id'] %}
    {% set filtered_change_data_columns = filtered_change_data_columns.append(col) %}
{% endfor %}


with change_data as (

    select *
    from {{ ref('marketo__change_data_scd') }}
    {% if is_incremental() %}
    where valid_to >= (select max(date_day) from {{ this }})
    {% endif %}

), calendar as (

    select *
    from {{ ref('marketo__lead_calendar_spine') }}
    where date_day <= current_date
    {% if is_incremental() %}
    and date_day >= (select max(date_day) from {{ this }})
    {% endif %}

), joined as (

    select 
        calendar.date_day,
        calendar.lead_id,
        change_data.lead_id is not null as new_values_present
        {% for col in filtered_change_data_columns %} 
        , {{ col.name }}
        {% endfor %}
    from calendar
    left join change_data
        on calendar.lead_id = change_data.lead_id
        and calendar.date_day = change_data.valid_to

), field_partitions as (

    select
        date_day,
        lead_id,
        new_values_present
        
        {% for col in filtered_change_data_columns %} 
        , joined.{{ col.name }}
        -- create a batch/partition once a new value is provided
        , sum(case when new_values_present then 1
            else 0 end) over (
                partition by lead_id
                order by coalesce(date_day, current_date) desc
                rows between unbounded preceding and current row)
            as {{ col.name }}_partition
        {% endfor %}
    from joined

), backfill as (

    select
        date_day,
        lead_id    
        -- For each lead on each day, find the state of each column from the next record where a change occurred,
        -- identified by the presence of a record from the SCD table on that day
        {% for col in filtered_change_data_columns %} 
        , first_value({{ col.name }}) over (
                partition by lead_id, {{ col.name }}_partition
                order by date_day desc 
                rows between unbounded preceding and current row)
        as {{ col.name }}
        {% endfor %}
    from field_partitions

), surrogate_key as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['date_day','lead_id'] )}} as lead_history_id
    from backfill

)

select *
from surrogate_key