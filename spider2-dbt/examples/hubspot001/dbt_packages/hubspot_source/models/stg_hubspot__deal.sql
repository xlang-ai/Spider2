{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__deal_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__deal_tmp')),
                staging_columns=get_deal_columns()
            )
        }}
    from base

), fields as (

    select

{% if var('hubspot__pass_through_all_columns', false) %}
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__deal_tmp')),
                staging_columns=get_deal_columns()
            )
        }}
        {% if all_passthrough_column_check('stg_hubspot__deal_tmp',get_deal_columns()) > 0 %}
        -- just pass everything through if extra columns are present, but ensure required columns are present.
        ,{{ 
            fivetran_utils.remove_prefix_from_columns(
                columns=adapter.get_columns_in_relation(ref('stg_hubspot__deal_tmp')), 
                prefix='property_',exclude=get_macro_columns(get_deal_columns()))
        }}
        {% endif %}
    from base

{% else %}
        -- just default columns + explicitly configured passthrough columns
        -- a few columns below are aliased within the macros/get_deal_columns.sql macro
        deal_name,
        cast(closed_date as {{ dbt.type_timestamp() }}) as closed_date,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        is_deal_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        deal_id,
        cast(deal_pipeline_id as {{ dbt.type_string() }}) as deal_pipeline_id,
        cast(deal_pipeline_stage_id as {{ dbt.type_string() }}) as deal_pipeline_stage_id,
        owner_id,
        portal_id,
        description,
        amount

        --The below macro adds the fields defined within your hubspot__deal_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('hubspot__deal_pass_through_columns') }}

        -- The below macro add the ability to create calculated fields using the hubspot__deal_calculated_fields variable.
        {{ fivetran_utils.calculated_fields('hubspot__deal_calculated_fields') }}

    from macro
{% endif %}

), joined as (
    {{ add_property_labels('hubspot__deal_pass_through_columns', cte_name='fields') }}
)

select *
from joined