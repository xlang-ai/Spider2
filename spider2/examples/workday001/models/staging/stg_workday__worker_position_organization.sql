
with base as (

    select * 
    from {{ ref('stg_workday__worker_position_organization_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__worker_position_organization_base')),
                staging_columns=get_worker_position_organization_history_columns()
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
        position_id,
        worker_id,
        _fivetran_synced, 
        index,   
        date_of_pay_group_assignment,
        organization_id,
        primary_business_site,
        used_in_change_organization_assignments as is_used_in_change_organization_assignments
    from fields
    where {{ dbt.current_timestamp() }} between _fivetran_start and _fivetran_end
)

select *
from final
