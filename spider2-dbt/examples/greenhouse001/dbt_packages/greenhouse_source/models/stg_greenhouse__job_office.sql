{{ config(enabled=var('greenhouse_using_job_office', True)) }}

with base as (

    select * 
    from {{ ref('stg_greenhouse__job_office_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__job_office_tmp')),
                staging_columns=get_job_office_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        office_id,
        job_id

    from fields
)

select * from final
