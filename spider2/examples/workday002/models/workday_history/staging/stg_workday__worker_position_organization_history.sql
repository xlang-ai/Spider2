{{ config(enabled=var('employee_history_enabled', False)) }}

with base as (

    select *      
    from {{ ref('stg_workday__worker_position_organization_base') }}
    {% if var('employee_history_start_date',[]) %}
    where cast(_fivetran_start as {{ dbt.type_timestamp() }}) >= "{{ var('employee_history_start_date') }}"
    {% endif %} 
),

fill_columns as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__worker_position_organization_base')),
                staging_columns=get_worker_position_organization_history_columns()
            )
        }}

        {{ 
            fivetran_utils.source_relation(
                union_schema_variable='workday_union_schemas', 
                union_database_variable='workday_union_databases'
                ) 
        }}

    from base
),

final as (

    select 
        {{ dbt_utils.generate_surrogate_key(['worker_id', 'position_id', 'organization_id', 'source_relation', '_fivetran_start']) }} as history_unique_key,
        worker_id,
        position_id,
        organization_id,
        source_relation,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_start as date) as _fivetran_date, 
        _fivetran_active,
        index,   
        date_of_pay_group_assignment, 
        primary_business_site,
        used_in_change_organization_assignments as is_used_in_change_organization_assignments
    from fill_columns
)

select *
from final