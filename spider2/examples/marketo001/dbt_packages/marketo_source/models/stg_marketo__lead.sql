with base as (

    select *
    from {{ ref('stg_marketo__lead_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_marketo__lead_tmp')),
                staging_columns=get_lead_columns()
            )
        }}
        -- This will check if there are non-default columns to bring in
        {% set default_cols = ['id', 'created_at', 'updated_at', 'email', 'first_name', 'last_name', '_fivetran_synced',
        'phone', 'main_phone', 'mobile_phone', 'company', 'inferred_company', 'address_lead', 'address', 'city', 'state',
        'state_code', 'country', 'country_code', 'postal_code', 'billing_street', 'billing_city', 'billing_state', 
        'billing_state_code', 'billing_country', 'billing_country_code', 'billing_postal_code', 'inferred_city', 'inferred_state_region', 
        'inferred_country', 'inferred_postal_code', 'inferred_phone_area_code', 'anonymous_ip', 'unsubscribed', 'email_invalid', 'do_not_call'] %}
        
        {% set new_cols = dbt_utils.star(from=ref('stg_marketo__lead_tmp'), except=default_cols) %}
        {% if new_cols != '/* no columns returned from star() macro */' %}
            ,{{ new_cols }} 
        {% endif %}
        
    from base

)

select *
from macro
