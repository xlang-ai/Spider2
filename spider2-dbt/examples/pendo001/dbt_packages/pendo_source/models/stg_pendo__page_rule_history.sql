
with base as (

    select * 
    from {{ ref('stg_pendo__page_rule_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__page_rule_history_tmp')),
                staging_columns=get_page_rule_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 

        designer_hint,
        page_id,
        page_last_updated_at,
        parsed_rule,
        rule,
        _fivetran_synced
        
    from fields
)

select * 
from final
