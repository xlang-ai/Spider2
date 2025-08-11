
with base as (

    select * 
    from {{ ref('stg_greenhouse__scorecard_attribute_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__scorecard_attribute_tmp')),
                staging_columns=get_scorecard_attribute_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        index,
        name as attribute_name,
        note,
        rating,
        scorecard_id,
        type as attribute_category

    from fields
)

select * from final
