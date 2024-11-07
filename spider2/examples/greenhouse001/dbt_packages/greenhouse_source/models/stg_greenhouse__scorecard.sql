
with base as (

    select * 
    from {{ ref('stg_greenhouse__scorecard_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__scorecard_tmp')),
                staging_columns=get_scorecard_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        application_id,
        candidate_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        id as scorecard_id,
        interview as interview_name,
        cast(interviewed_at as {{ dbt.type_timestamp() }}) as interviewed_at,
        overall_recommendation,
        cast(submitted_at as {{ dbt.type_timestamp() }}) as submitted_at,
        submitted_by_user_id,
        cast(updated_at as {{ dbt.type_timestamp() }}) as last_updated_at

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
