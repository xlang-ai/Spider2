{{ config(enabled=var('hubspot_service_enabled', False)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__ticket_engagement_tmp') }}

), macro as (

    select
        {% set default_cols = adapter.get_columns_in_relation(ref('stg_hubspot__ticket_engagement_tmp')) %}
        {% set new_cols = remove_duplicate_and_prefix_from_columns(columns=default_cols, 
            prefix='property_hs_',exclude=get_macro_columns(get_ticket_engagement_columns())) %}
        {{
            fivetran_utils.fill_staging_columns(source_columns=default_cols,
                staging_columns=get_ticket_engagement_columns()
            )
        }}
        {% if new_cols | length > 0 %} 
            {{ new_cols }} 
        {% endif %}
    from base

)

select *
from macro
