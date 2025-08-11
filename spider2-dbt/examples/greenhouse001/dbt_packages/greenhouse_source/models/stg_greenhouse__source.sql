
with base as (

    select * 
    from {{ ref('stg_greenhouse__source_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__source_tmp')),
                staging_columns=get_source_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        id as source_id,
        name as source_name,
        source_type_id,
        source_type_name

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
