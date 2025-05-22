{{ config(enabled=var('greenhouse_using_app_history', True)) }}

with base as (

    select * 
    from {{ ref('stg_greenhouse__application_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__application_history_tmp')),
                staging_columns=get_application_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        application_id,
        new_stage_id,
        new_status,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at
        
    from fields
)

select * from final
