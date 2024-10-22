
with base as (

    select * 
    from {{ ref('stg_pendo__account_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__account_history_tmp')),
                staging_columns=get_account_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as account_id,
        last_updated_at,
        id_hash as account_id_hash,
        first_visit as first_visit_at,
        last_visit as last_visit_at,
        _fivetran_synced

        --The below macro adds the fields defined within your pendo__account_history_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('pendo__account_history_pass_through_columns') }}
        
    from fields
)

select * 
from final
