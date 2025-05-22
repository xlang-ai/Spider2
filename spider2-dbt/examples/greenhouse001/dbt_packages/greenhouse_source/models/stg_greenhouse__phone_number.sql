
with base as (

    select * 
    from {{ ref('stg_greenhouse__phone_number_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__phone_number_tmp')),
                staging_columns=get_phone_number_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        candidate_id,
        index,
        type as phone_type,
        value as phone_number

    from fields

)

select * from final