
with base as (

    select * 
    from {{ ref('stg_greenhouse__tag_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__tag_tmp')),
                staging_columns=get_tag_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        id as tag_id,
        name as tag_name

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
