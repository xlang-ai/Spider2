
with base as (

    select * 
    from {{ ref('stg_greenhouse__attachment_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__attachment_tmp')),
                staging_columns=get_attachment_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        candidate_id,
        filename,
        index,
        type,
        url

    from fields
)

select * from final
