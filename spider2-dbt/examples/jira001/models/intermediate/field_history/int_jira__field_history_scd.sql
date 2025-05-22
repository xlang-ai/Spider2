{{ config( materialized='table') }}

{%- set issue_columns = adapter.get_columns_in_relation(ref('int_jira__pivot_daily_field_history')) -%}

with change_data as (

    select *
    from {{ ref('int_jira__pivot_daily_field_history') }}

), set_values as (

    select 
        valid_starting_on, 
        issue_id,
        issue_day_id,
        status as status_id,
        sum( case when status is null then 0 else 1 end) over ( partition by issue_id 
            order by valid_starting_on rows unbounded preceding) as status_id_field_partition

        {% for col in issue_columns if col.name|lower not in ['valid_starting_on','issue_id','issue_day_id'] %} 
        , {{ col.name }}
        -- create a batch/partition once a new value is provided
        , sum( case when {{ col.name }} is null then 0 else 1 end) over ( partition by issue_id 
            order by valid_starting_on rows unbounded preceding) as {{ col.name }}_field_partition

        {% endfor %}
    
    from change_data

), fill_values as (

-- each row of the pivoted table includes field values if that field was updated on that day
-- we need to backfill to persist values that have been previously updated and are still valid 
    select 
        valid_starting_on, 
        issue_id,
        issue_day_id,
        first_value( status ) over (
            partition by issue_id, status_id_field_partition 
            order by valid_starting_on asc rows between unbounded preceding and current row) as status_id
        
        {% for col in issue_columns if col.name|lower not in ['valid_starting_on','issue_id','issue_day_id'] %} 

        -- grab the value that started this batch/partition
        , first_value( {{ col.name }} ) over (
            partition by issue_id, {{ col.name }}_field_partition 
            order by valid_starting_on asc rows between unbounded preceding and current row) as {{ col.name }}

        {% endfor %}

    from set_values

)

select *
from fill_values