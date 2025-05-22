{{
    config(
        materialized='incremental',
        partition_by = {'field': 'valid_to', 'data_type': 'date'} if target.type not in ['spark','databricks'] else ['valid_to'],
        unique_key='lead_day_id',
        incremental_strategy='delete+insert' if target.type not in ['postgres', 'redshift'] else 'delete+insert',
        file_format='delta'
        ) 
}}

{%- set lead_columns = adapter.get_columns_in_relation(ref('int_marketo__lead')) -%}
{% set filtered_lead_columns = [] %}
{% for col in lead_columns if col.name|lower not in ['lead_id','_fivetran_synced'] and col.name|lower in var('lead_history_columns') %}
    {% set filtered_lead_columns = filtered_lead_columns.append(col) %}
{% endfor %}

{%- set change_data_columns = adapter.get_columns_in_relation(ref('marketo__change_data_pivot')) -%}
{%- set change_data_columns_xf = change_data_columns|map(attribute='name')|list %}

with change_data as (

    select *
    from {{ ref('marketo__change_data_pivot') }}
    {% if is_incremental() %}
    where date_day >= (select max(valid_to) from {{ this }})
    {% endif %}

), leads as (

    select *
    from {{ ref('int_marketo__lead') }}

), details as (

    select *
    from {{ ref('marketo__change_data_details') }}
    {% if is_incremental() %}
    where date_day >= (select max(valid_to) from {{ this }})
    {% endif %}

), unioned as (

    -- unions together the current state of leads and their history changes. 
    -- we need the current state to work backwards from to backfill the slowly changing dimension model

    {{ 
        fivetran_utils.union_relations(
            relations=[ref('int_marketo__lead'), ref('marketo__change_data_pivot')],
            aliases=['leads','change_data']
            ) 
    }}

), field_partitions as (

    select
        coalesce(unioned.date_day, current_date) as valid_to,
        unioned.date_day,
        unioned.lead_id
        
        {% for col in filtered_lead_columns %}
        {% if col.name not in change_data_columns_xf %}
        , unioned.{{ col.name }}
        , null as {{ col.name }}_partition

        {% else %}
        , unioned.{{ col.name }}
        , sum(case when unioned.{{ col.name }} is null and not coalesce(details.{{ col.name }}, true) then 0
            else 1 end) over (
                partition by unioned.lead_id
                order by coalesce(unioned.date_day, current_date) desc 
                rows between unbounded preceding and current row)
            as {{ col.name }}_partition
        
        {% endif %}
        {% endfor %}

    from unioned
    left join details
        on unioned.date_day = details.date_day
        and unioned.lead_id = details.lead_id

), today as (

    -- For each day where a change occurred for each lead, we backfill the values from the subsequent change, going back in time.
    -- The 'details' table is joined in for exactly this purpose. It tells us, even if a value is null, whether that null
    -- value is because no change occurred on that day, or because there was a change and the change involved the null value.

    select 
        field_partitions.valid_to, 
        field_partitions.lead_id

        {% for col in filtered_lead_columns %} 
        {% if col.name not in change_data_columns_xf %}
        {# If the column does not exist in the change data, grab the value from the current state of the record. #}
        , last_value(field_partitions.{{ col.name }}) over (
            partition by field_partitions.lead_id 
            order by field_partitions.date_day asc 
            rows between unbounded preceding and current row) as {{ col.name }}

        {% else %}
        , first_value(field_partitions.{{ col.name }}) over (
            partition by field_partitions.lead_id, field_partitions.{{ col.name }}_partition 
            order by field_partitions.valid_to desc
            rows between unbounded preceding and current row)
            as {{ col.name }}
        {% endif %}
        {% endfor %}

    from field_partitions

), surrogate_key as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['lead_id','valid_to'])}} as lead_day_id
    from today

)

select *
from surrogate_key