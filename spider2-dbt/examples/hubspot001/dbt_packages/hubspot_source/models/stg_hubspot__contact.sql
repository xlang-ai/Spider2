{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__contact_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__contact_tmp')),
                staging_columns=get_contact_columns()
            )
        }}
    from base

), fields as (

    select

{% if var('hubspot__pass_through_all_columns', false) %}
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__contact_tmp')),
                staging_columns=get_contact_columns()
            )
        }}
        {% if all_passthrough_column_check('stg_hubspot__contact_tmp',get_contact_columns()) > 0 %}
        -- just pass everything through if extra columns are present, but ensure required columns are present.
        ,{{ 
            fivetran_utils.remove_prefix_from_columns(
                columns=adapter.get_columns_in_relation(ref('stg_hubspot__contact_tmp')), 
                prefix='property_', exclude=get_macro_columns(get_contact_columns())) 
        }}
        {% endif %}
    from base

{% else %}
        -- just default columns + explicitly configured passthrough columns.
        -- a few columns below are aliased within the macros/get_contact_columns.sql macro
        contact_id,
        is_contact_deleted,
        calculated_merged_vids, -- will be null for BigQuery users until v3 api is rolled out to them
        email,
        contact_company,
        first_name,
        last_name,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_date,
        job_title,
        company_annual_revenue,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced

        --The below macro adds the fields defined within your hubspot__contact_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('hubspot__contact_pass_through_columns') }}

        -- The below macro add the ability to create calculated fields using the hubspot__contact_calculated_fields variable.
        {{ fivetran_utils.calculated_fields('hubspot__contact_calculated_fields') }}

    from macro
{% endif %}    

), joined as (
    {{ add_property_labels('hubspot__contact_pass_through_columns', cte_name='fields') }}
)

select *
from joined