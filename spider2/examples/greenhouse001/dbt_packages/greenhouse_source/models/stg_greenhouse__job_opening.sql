
with base as (

    select * 
    from {{ ref('stg_greenhouse__job_opening_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__job_opening_tmp')),
                staging_columns=get_job_opening_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        application_id,
        close_reason_id,
        cast(closed_at as {{ dbt.type_timestamp() }}) as closed_at,
        id as job_openining_id,
        job_id,
        cast(opened_at as {{ dbt.type_timestamp() }}) as opened_at,
        opening_id as opening_text_id,
        status as current_status

    from fields
)

select * from final
