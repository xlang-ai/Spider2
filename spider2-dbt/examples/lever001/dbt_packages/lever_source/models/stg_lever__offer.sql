
with base as (

    select * 
    from {{ ref('stg_lever__offer_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__offer_tmp')),
                staging_columns=get_offer_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        creator_id as creator_user_id,
        id as offer_id,
        status,
        candidate_id as opportunity_id -- todo surface this issue
    from fields
)

select * 
from final
