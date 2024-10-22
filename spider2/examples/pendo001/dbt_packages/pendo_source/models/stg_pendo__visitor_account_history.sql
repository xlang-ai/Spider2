
with base as (

    select * 
    from {{ ref('stg_pendo__visitor_account_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__visitor_account_history_tmp')),
                staging_columns=get_visitor_account_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        account_id,
        visitor_id,
        visitor_last_updated_at,
        _fivetran_synced
        
    from fields
)

select * 
from final
