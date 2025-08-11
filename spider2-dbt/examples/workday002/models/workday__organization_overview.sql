with organization_data as (

    select * 
    from {{ ref('stg_workday__organization') }}
),

organization_role_data as (

    select * 
    from {{ ref('stg_workday__organization_role') }}
),

worker_position_organization as (

    select *
    from {{ ref('stg_workday__worker_position_organization') }}
),

organization_roles as (

    select 
        organization_role_data.organization_id,
        organization_role_data.source_relation,
        organization_role_data.organization_role_id,
        organization_role_data.organization_role_code,
        worker_position_organization.worker_id,
        worker_position_organization.position_id
    from organization_role_data
    left join worker_position_organization
        on organization_role_data.organization_id = worker_position_organization.organization_id 
        and organization_role_data.source_relation = worker_position_organization.source_relation
),

organization_data_enhanced as (

    select   
        organization_data.organization_id,
        organization_roles.organization_role_id,
        organization_roles.worker_id,
        organization_roles.position_id,
        organization_data.source_relation,
        organization_data.organization_code,
        organization_data.organization_name,
        organization_data.organization_type,
        organization_data.organization_sub_type,
        organization_data.superior_organization_id,
        organization_data.top_level_organization_id, 
        organization_data.manager_id,
        organization_roles.organization_role_code
    from organization_data
    left join organization_roles 
        on organization_roles.organization_id = organization_data.organization_id 
        and organization_roles.source_relation = organization_data.source_relation
)

select *
from organization_data_enhanced