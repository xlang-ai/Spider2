
with base as (

    select * 
    from {{ ref('stg_greenhouse__job_stage_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__job_stage_tmp')),
                staging_columns=get_job_stage_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        id as job_stage_id,
        job_id,
        name as stage_name,
        cast(updated_at as {{ dbt.type_timestamp() }}) as last_updated_at

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
