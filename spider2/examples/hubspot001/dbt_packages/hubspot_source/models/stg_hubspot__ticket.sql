{{ config(enabled=var('hubspot_service_enabled', False)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__ticket_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__ticket_tmp')),
                staging_columns=get_ticket_columns()
            )
        }}
    from base

), fields as (

    select

{% if var('hubspot__pass_through_all_columns', false) %}
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__ticket_tmp')),
                staging_columns=get_ticket_columns()
            )
        }}
        {% if all_passthrough_column_check('stg_hubspot__ticket_tmp',get_ticket_columns()) > 0 %}
        -- just pass everything through if extra columns are present, but ensure required columns are present.
        {{  
            remove_duplicate_and_prefix_from_columns(
                columns=adapter.get_columns_in_relation(ref('stg_hubspot__ticket_tmp')), 
                prefix='property_', exclude=get_macro_columns(get_ticket_columns())) 
        }}
        {% endif %}
    from base

{% else %}
        -- just default columns + explicitly configured passthrough columns
        -- a few columns below are aliased within the macros/get_ticket_columns.sql macro
        ticket_id,
        coalesce(_fivetran_ticket_deleted, is_ticket_deleted) as is_ticket_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(closed_date as {{ dbt.type_timestamp() }}) as closed_date,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        first_agent_reply_at,
        ticket_pipeline_id,
        ticket_pipeline_stage_id,
        ticket_category,
        ticket_priority,
        owner_id,
        ticket_subject,
        ticket_content

        --The below macro adds the fields defined within your hubspot__ticket_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('hubspot__ticket_pass_through_columns') }}

        -- The below macro add the ability to create calculated fields using the hubspot__ticket_calculated_fields variable.
        {{ fivetran_utils.calculated_fields('hubspot__ticket_calculated_fields') }}
        
    from macro
{% endif %}

), joined as (
    {{ add_property_labels('hubspot__ticket_pass_through_columns', cte_name='fields') }}
)

select *
from joined