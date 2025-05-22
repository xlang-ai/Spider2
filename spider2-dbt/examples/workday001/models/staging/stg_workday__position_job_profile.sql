
with base as (

    select * 
    from {{ ref('stg_workday__position_job_profile_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__position_job_profile_base')),
                staging_columns=get_position_job_profile_columns()
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
        difficulty_to_fill_code,
        is_critical_job,
        job_category_code,
        job_profile_id,
        management_level_code,
        name as position_job_profile_name,
        position_id,
        work_shift_required as is_work_shift_required
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
