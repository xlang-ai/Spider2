
with base as (

    select * 
    from {{ ref('stg_pendo__event_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__event_tmp')),
                staging_columns=get_event_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        visitor_id,
        account_id,
        app_id,
        page_id,
        remote_ip,
        server_name,
        timestamp as occurred_at,
        user_agent,
        num_events,
        num_minutes,
        _fivetran_synced,
        _fivetran_id,
        {{ dbt_utils.generate_surrogate_key(['visitor_id', 'timestamp', 'account_id', 'server_name', 'user_agent', 'remote_ip', '_fivetran_id']) }} 
            as event_key

        --The below macro adds the fields defined within your pendo__event_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('pendo__event_pass_through_columns') }}

    from fields
)

select * 
from final
