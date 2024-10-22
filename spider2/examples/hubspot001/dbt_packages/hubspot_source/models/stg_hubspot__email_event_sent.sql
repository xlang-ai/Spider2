{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_email_event_sent_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__email_event_sent_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__email_event_sent_tmp')),
                staging_columns=get_email_event_sent_columns()
            )
        }}
    from base

), fields as (

    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        bcc as bcc_emails,
        cc as cc_emails,
        from_email, -- source field name = from ; alias declared in macros/get_email_event_sent_columns.sql
        id as event_id,
        reply_to as reply_to_email,
        subject as email_subject
    from macro
    
)

select *
from fields