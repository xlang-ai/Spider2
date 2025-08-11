{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_email_event_status_change_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__email_event_status_change_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__email_event_status_change_tmp')),
                staging_columns=get_email_event_status_change_columns()
            )
        }}
    from base

), fields as (

    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        bounced as is_bounced,
        id as event_id,
        portal_subscription_status as subscription_status,
        requested_by as requested_by_email,
        source as change_source,
        subscriptions
    from macro
    
)

select *
from fields


