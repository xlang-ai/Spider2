
with base as (

    select * 
    from {{ ref('stg_greenhouse__email_address_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__email_address_tmp')),
                staging_columns=get_email_address_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        candidate_id,
        index,
        type,
        value as email
        
    from fields
)

select * from final
