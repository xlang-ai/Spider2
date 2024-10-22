{{ config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_contact_merge_audit_enabled', false))) }}

with base as (

    select *
    from {{ ref('stg_hubspot__contact_merge_audit_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__contact_merge_audit_tmp')),
                staging_columns=get_contact_merge_audit_columns()
            )
        }}
    from base

), fields as (

    select
        canonical_vid,
        contact_id,
        entity_id,
        first_name,
        last_name,
        num_properties_moved,
        cast(
        {%- if target.type == 'redshift' %}
        "timestamp"
        {%- else %}
        timestamp
        {%- endif %}
        as {{ dbt.type_timestamp() }}) as timestamp_at,
        user_id,
        vid_to_merge,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from macro
    
)

select *
from fields
