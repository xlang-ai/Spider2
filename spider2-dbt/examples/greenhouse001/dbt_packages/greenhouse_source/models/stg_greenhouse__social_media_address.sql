
with base as (

    select * 
    from {{ ref('stg_greenhouse__social_media_address_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__social_media_address_tmp')),
                staging_columns=get_social_media_address_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        candidate_id,
        index,
        value as url
        
    from fields
)

select * from final
