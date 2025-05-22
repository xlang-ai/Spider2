
with base as (

    select * 
    from {{ ref('stg_greenhouse__activity_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__activity_tmp')),
                staging_columns=get_activity_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        body,
        candidate_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as occurred_at,
        id as activity_id,
        subject,
        user_id

    from fields
)

select * from final
