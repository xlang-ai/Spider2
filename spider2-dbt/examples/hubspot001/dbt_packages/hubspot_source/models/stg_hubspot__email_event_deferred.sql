{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_email_event_deferred_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__email_event_deferred_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__email_event_deferred_tmp')),
                staging_columns=get_email_event_deferred_columns()
            )
        }}
    from base

), fields as (

    select
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        attempt as attempt_number,
        id as event_id,
        response as returned_response
    from macro
    
)

select *
from fields


