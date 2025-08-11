
with base as (

    select * 
    from {{ ref('stg_pendo__visitor_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__visitor_history_tmp')),
                staging_columns=get_visitor_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as visitor_id,
        account_id,
        first_visit as first_visit_at,
        id_hash as visitor_id_hash,
        last_browser_name,
        last_browser_version,
        last_operating_system,
        last_server_name,
        last_updated_at,
        last_user_agent,
        last_visit,
        n_id,
        _fivetran_synced

        --The below macro adds the fields defined within your pendo__visitor_history_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('pendo__visitor_history_pass_through_columns') }}

    from fields
)

select * 
from final
