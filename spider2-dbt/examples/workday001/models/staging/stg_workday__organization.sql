
with base as (

    select * 
    from {{ ref('stg_workday__organization_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__organization_base')),
                staging_columns=get_organization_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='workday_union_schemas', 
            union_database_variable='workday_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation,
        _fivetran_synced,
        availability_date,
        available_for_hire as is_available_for_hire,
        code,
        description as organization_description,
        external_url,
        hiring_freeze as is_hiring_freeze,
        id as organization_id,
        inactive as is_inactive,
        inactive_date,
        include_manager_in_name as is_include_manager_in_name,
        include_organization_code_in_name as is_include_organization_code_in_name,
        last_updated_date_time,
        location as organization_location,
        manager_id,
        name as organization_name,
        organization_code,
        organization_owner_id,
        staffing_model,
        sub_type as organization_sub_type,
        superior_organization_id,
        supervisory_position_availability_date,
        supervisory_position_earliest_hire_date,
        supervisory_position_time_type,
        supervisory_position_worker_type,
        top_level_organization_id,
        type as organization_type,
        visibility
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
