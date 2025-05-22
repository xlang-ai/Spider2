{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__email_event_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__email_event_tmp')),
                staging_columns=get_email_event_columns()
            )
        }}
    from base

), fields as (

    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        app_id,
        cast(caused_by_created as {{ dbt.type_timestamp() }}) as caused_timestamp,
        caused_by_id as caused_by_event_id,
        cast(created as {{ dbt.type_timestamp() }}) as created_timestamp,
        email_campaign_id,
        filtered_event as is_filtered_event,
        id as event_id,
        cast(obsoleted_by_created as {{ dbt.type_timestamp() }}) as obsoleted_timestamp,
        obsoleted_by_id as obsoleted_by_event_id,
        portal_id,
        recipient as recipient_email_address,
        cast(sent_by_created as {{ dbt.type_timestamp() }}) as sent_timestamp,
        sent_by_id as sent_by_event_id,
        type as event_type
    from macro
    
)

select *
from fields
{% if not var('hubspot_using_all_email_events',true) -%}
where not coalesce(is_filtered_event, false)
{%- endif -%}
