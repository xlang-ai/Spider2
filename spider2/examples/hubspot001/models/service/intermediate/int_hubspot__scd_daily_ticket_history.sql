{{ config(materialized='table', enabled=var('hubspot_service_enabled', False)) }}

{%- set ticket_columns = adapter.get_columns_in_relation(ref('int_hubspot__pivot_daily_ticket_history')) -%}

with change_data as (

    select *
    from {{ ref('int_hubspot__pivot_daily_ticket_history') }}

), set_values as (

    select 
        date_day, 
        ticket_id,
        id

        {% for col in ticket_columns if col.name|lower not in ['date_day','ticket_id','id'] %} 
        , {{ col.name }} as {{ col.name|lower }}
        -- create a batch/partition once a new value is provided
        , sum( case when {{ col.name }} is null then 0 else 1 end) over (partition by ticket_id 
            order by date_day rows unbounded preceding) as {{ col.name }}_field_partition

        {% endfor %}
    
    from change_data

), fill_values as (

-- each row of the pivoted table includes ticket property values if that property was updated on that day
-- we need to backfill to persist values that have been previously updated and are still valid 
    select 
        date_day, 
        ticket_id,
        id
        
        {% for col in ticket_columns if col.name|lower not in ['date_day','ticket_id','id'] %} 

        -- grab the value that started this batch/partition
        , first_value( {{ col.name }} ) over (
            partition by ticket_id, {{ col.name }}_field_partition 
            order by date_day asc rows between unbounded preceding and current row) as {{ col.name }}

        {% endfor %}

    from set_values

)

select *
from fill_values