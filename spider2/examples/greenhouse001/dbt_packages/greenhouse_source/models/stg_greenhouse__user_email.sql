
with base as (

    select * 
    from {{ ref('stg_greenhouse__user_email_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__user_email_tmp')),
                staging_columns=get_user_email_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        email,
        user_id
        
    from fields
)

select * from final
