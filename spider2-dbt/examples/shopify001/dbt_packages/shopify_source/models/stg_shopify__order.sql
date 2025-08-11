with base as (

    select * 
    from {{ ref('stg_shopify__order_tmp') }}

),

fields as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__order_tmp')),
                staging_columns=get_order_columns()
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
        id as order_id,
        user_id,
        total_discounts,
        total_discounts_set,
        total_line_items_price,
        total_line_items_price_set,
        total_price,
        total_price_set,
        total_tax_set,
        total_tax,
        source_name,
        subtotal_price,
        taxes_included as has_taxes_included,
        total_weight,
        total_tip_received,
        landing_site_base_url,
        location_id,
        name,
        note,
        number,
        order_number,
        cancel_reason,
        cart_token,
        checkout_token,
        {{ dbt_date.convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_timestamp,
        {{ dbt_date.convert_timezone(column='cast(cancelled_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as cancelled_timestamp,
        {{ dbt_date.convert_timezone(column='cast(closed_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as closed_timestamp,
        {{ dbt_date.convert_timezone(column='cast(processed_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as processed_timestamp,
        {{ dbt_date.convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_timestamp,
        currency,
        customer_id,
        lower(email) as email,
        financial_status,
        fulfillment_status,
        referring_site,
        billing_address_address_1,
        billing_address_address_2,
        billing_address_city,
        billing_address_company,
        billing_address_country,
        billing_address_country_code,
        billing_address_first_name,
        billing_address_last_name,
        billing_address_latitude,
        billing_address_longitude,
        billing_address_name,
        billing_address_phone,
        billing_address_province,
        billing_address_province_code,
        billing_address_zip,
        browser_ip,
        total_shipping_price_set,
        shipping_address_address_1,
        shipping_address_address_2,
        shipping_address_city,
        shipping_address_company,
        shipping_address_country,
        shipping_address_country_code,
        shipping_address_first_name,
        shipping_address_last_name,
        shipping_address_latitude,
        shipping_address_longitude,
        shipping_address_name,
        shipping_address_phone,
        shipping_address_province,
        shipping_address_province_code,
        shipping_address_zip,
        token,
        app_id,
        checkout_id,
        client_details_user_agent,
        customer_locale,
        order_status_url,
        presentment_currency,
        test as is_test_order,
        _fivetran_deleted as is_deleted,
        buyer_accepts_marketing as has_buyer_accepted_marketing,
        confirmed as is_confirmed,
        {{ dbt_date.convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

        {{ fivetran_utils.fill_pass_through_columns('order_pass_through_columns') }}

    from fields
)

select * 
from final
where not coalesce(is_test_order, false)
and not coalesce(is_deleted, false)