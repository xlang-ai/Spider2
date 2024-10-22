{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_company_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__company_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__company_tmp')),
                staging_columns=get_company_columns()
            )
        }}
    from base

), fields as (

    select

{% if var('hubspot__pass_through_all_columns', false) %}
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__company_tmp')),
                staging_columns=get_company_columns()
            )
        }}
        {% if all_passthrough_column_check('stg_hubspot__company_tmp',get_company_columns()) > 0 %}
        -- just pass everything through if extra columns are present, but ensure required columns are present.
        ,{{ 
            fivetran_utils.remove_prefix_from_columns(
                columns=adapter.get_columns_in_relation(ref('stg_hubspot__company_tmp')), 
                prefix='property_', exclude=get_macro_columns(get_company_columns()))
        }}
        {% endif %}
    from base

{% else %}
        -- just default columns + explicitly configured passthrough columns
        -- a few columns below are aliased within the macros/get_company_columns.sql macro
        company_id,
        is_company_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        company_name,
        description,
        created_date,
        industry,
        street_address,
        street_address_2,
        city,
        state,
        country,
        company_annual_revenue
        
        --The below macro adds the fields defined within your hubspot__ticket_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('hubspot__company_pass_through_columns') }}

        -- The below macro add the ability to create calculated fields using the hubspot__company_calculated_fields variable.
        {{ fivetran_utils.calculated_fields('hubspot__company_calculated_fields') }}
        
    from macro

{% endif %}

), joined as (
    {{ add_property_labels('hubspot__company_pass_through_columns', cte_name='fields') }}
)

select *
from joined