
with base as (

    select * 
    from {{ ref('stg_workday__job_family_job_family_group_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__job_family_job_family_group_base')),
                staging_columns=get_job_family_job_family_group_columns()
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
        job_family_id,
        job_family_group_id
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final