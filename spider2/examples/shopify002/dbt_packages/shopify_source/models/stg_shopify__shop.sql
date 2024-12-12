
with base as (

    select * 
    from {{ ref('stg_shopify__shop_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__shop_tmp')),
                staging_columns=get_shop_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='shopify_union_schemas', 
            union_database_variable='shopify_union_databases') 
        }}

    from base
),

final as (
    
    select 
        id as shop_id,
        name,
        _fivetran_deleted as is_deleted,
        address_1,
        address_2,
        city,
        province,
        province_code,
        country,
        country_code,
        country_name,
        zip,
        latitude,
        longitude,
        case when county_taxes is null then false else county_taxes end as has_county_taxes,
        currency,
        enabled_presentment_currencies,
        customer_email,
        email,
        domain,
        phone,
        timezone,
        iana_timezone,
        primary_locale,
        weight_unit,
        myshopify_domain,
        cookie_consent_level,
        shop_owner,
        source,
        tax_shipping as has_shipping_taxes,
        case when taxes_included is null then false else taxes_included end as has_taxes_included_in_price,
        has_discounts,
        has_gift_cards,
        has_storefront,
        checkout_api_supported as has_checkout_api_supported,
        eligible_for_card_reader_giveaway as is_eligible_for_card_reader_giveaway,
        eligible_for_payments as is_eligible_for_payments,
        google_apps_domain,
        case when google_apps_login_enabled is null then false else google_apps_login_enabled end as is_google_apps_login_enabled,
        money_format,
        money_in_emails_format,
        money_with_currency_format,
        money_with_currency_in_emails_format,
        plan_display_name,
        plan_name,
        password_enabled as is_password_enabled,
        pre_launch_enabled as is_pre_launch_enabled,
        requires_extra_payments_agreement as is_extra_payments_agreement_required,
        setup_required as is_setup_required,
        {{ dbt_date.convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_at,
        {{ dbt_date.convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ dbt_date.convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

    from fields
)

select *
from final
