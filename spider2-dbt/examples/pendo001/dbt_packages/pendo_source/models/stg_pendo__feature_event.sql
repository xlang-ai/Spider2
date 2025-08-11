
with base as (

    select * 
    from {{ ref('stg_pendo__feature_event_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__feature_event_tmp')),
                staging_columns=get_feature_event_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        account_id,
        app_id,
        feature_id,
        num_events,
        num_minutes,
        remote_ip,
        server_name,
        timestamp as occurred_at,
        user_agent,
        visitor_id,
        _fivetran_synced,
        _fivetran_id,
        {{ dbt_utils.generate_surrogate_key(
            ['visitor_id', 'timestamp', 'account_id', 'server_name', 'feature_id', 'remote_ip', 'user_agent', '_fivetran_id']
            ) }} as feature_event_key

        --The below macro adds the fields defined within your pendo__feature_event_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('pendo__feature_event_pass_through_columns') }}
        
    from fields
)

select * 
from final
