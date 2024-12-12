{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__email_campaign_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__email_campaign_tmp')),
                staging_columns=get_email_campaign_columns()
            )
        }}
    from base

), fields as (

    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        app_id,
        app_name,
        content_id,
        id as email_campaign_id,
        name as email_campaign_name,
        num_included,
        num_queued,
        sub_type as email_campaign_sub_type,
        subject as email_campaign_subject,
        type as email_campaign_type
    from macro
    
)

select *
from fields


