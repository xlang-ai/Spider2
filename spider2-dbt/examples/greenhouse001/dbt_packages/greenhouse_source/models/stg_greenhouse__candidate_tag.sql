
with base as (

    select * 
    from {{ ref('stg_greenhouse__candidate_tag_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__candidate_tag_tmp')),
                staging_columns=get_candidate_tag_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        candidate_id,
        tag_id
        
    from fields
)

select * from final
