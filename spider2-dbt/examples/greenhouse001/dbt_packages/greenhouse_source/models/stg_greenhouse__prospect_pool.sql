{{ config(enabled=var('greenhouse_using_prospects', True)) }}

with base as (

    select * 
    from {{ ref('stg_greenhouse__prospect_pool_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__prospect_pool_tmp')),
                staging_columns=get_prospect_pool_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        active as is_active,
        id as prospect_pool_id,
        name as prospect_pool_name

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
