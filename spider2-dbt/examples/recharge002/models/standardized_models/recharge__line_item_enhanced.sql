{{ config(enabled=var('recharge__standardized_billing_model_enabled', False)) }}

with charge_line_items as (

    select * 
    from {{ var('charge_line_item')}}

), charges as (

    select * 
    from {{ var('charge') }}

), charge_shipping_lines as (

    select
        charge_id,
        sum(price) as total_shipping
    from {{ var('charge_shipping_line') }}
    group by 1

{% if var('recharge__checkout_enabled', false) %}
), checkouts as (

    select *
    from {{ var('checkout') }}

{% endif %}

), addresses as (

    select * 
    from {{ var('address') }}

), customers as (

    select * 
    from {{ var('customer') }}

), subscriptions as (

    select *
    from {{ var('subscription_history') }} 
    where is_most_recent_record

), enhanced as (
    select
        cast(charge_line_items.charge_id as {{ dbt.type_string() }}) as header_id,
        cast(charge_line_items.index as {{ dbt.type_string() }}) as line_item_id,
        row_number() over (partition by charge_line_items.charge_id
            order by charge_line_items.index) as line_item_index,

        -- header level fields
        charges.charge_created_at as created_at,
        charges.charge_status as header_status,
        cast(charges.total_discounts as {{ dbt.type_numeric() }}) as discount_amount,
        cast(charges.total_refunds as {{ dbt.type_numeric() }}) as refund_amount,
        cast(charge_shipping_lines.total_shipping as {{ dbt.type_numeric() }}) as fee_amount,
        addresses.payment_method_id,
        charges.external_transaction_id_payment_processor as payment_id,
        charges.payment_processor as payment_method,
        charges.charge_processed_at as payment_at,
        charges.charge_type as billing_type,  -- possible values: checkout, recurring

        -- Currency is in the Charges api object but not the Fivetran schema, so relying on Checkouts for now.
        -- Checkouts has only 20% utilization, so we should switch to the Charges field when it is added.
        cast({{ 'checkouts.currency' if var('recharge__using_checkout', false) else 'null' }} as {{ dbt.type_string() }}) as currency,

        -- line item level fields
        cast(charge_line_items.purchase_item_type as {{ dbt.type_string() }}) as transaction_type, -- possible values: subscription, onetime
        cast(charge_line_items.external_product_id_ecommerce as {{ dbt.type_string() }}) as product_id,
        cast(charge_line_items.title as {{ dbt.type_string() }}) as product_name,
        cast(null as {{ dbt.type_string() }}) as product_type, -- product_type not available
        cast(charge_line_items.quantity as {{ dbt.type_int() }}) as quantity,
        cast(charge_line_items.unit_price as {{ dbt.type_numeric() }}) as unit_amount,
        cast(charge_line_items.tax_due as {{ dbt.type_numeric() }}) as tax_amount,
        cast(charge_line_items.total_price as {{ dbt.type_numeric() }}) as total_amount,
        case when charge_line_items.purchase_item_type = 'subscription'
            then cast(charge_line_items.purchase_item_id as {{ dbt.type_string() }})
            end as subscription_id,
        subscriptions.product_title as subscription_plan,
        subscriptions.subscription_created_at as subscription_period_started_at,
        subscriptions.subscription_cancelled_at as subscription_period_ended_at,
        cast(subscriptions.subscription_status as {{ dbt.type_string() }}) as subscription_status,
        'customer' as customer_level,
        cast(charges.customer_id as {{ dbt.type_string() }}) as customer_id,
        cast(customers.customer_created_at as {{ dbt.type_timestamp() }}) as customer_created_at,
        -- coalesces are since information may be incomplete in various tables and casts for consistency
        coalesce(
            cast(charges.email as {{ dbt.type_string() }}),
            cast(customers.email as {{ dbt.type_string() }})
            ) as customer_email,
        coalesce(
            {{ dbt.concat(["customers.billing_first_name", "' '", "customers.billing_last_name"]) }},
            {{ dbt.concat(["addresses.first_name", "' '", "addresses.last_name"]) }}
            ) as customer_name,
        coalesce(cast(customers.billing_company as {{ dbt.type_string() }}),
            cast(addresses.company as {{ dbt.type_string() }})
            ) as customer_company,
        coalesce(cast(customers.billing_city as {{ dbt.type_string() }}),
            cast(addresses.city as {{ dbt.type_string() }})
            ) as customer_city,
        coalesce(cast(customers.billing_country as {{ dbt.type_string() }}),
            cast(addresses.country as {{ dbt.type_string() }})
            ) as customer_country

    from charge_line_items

    left join charges
        on charges.charge_id = charge_line_items.charge_id

    left join addresses
        on addresses.address_id = charges.address_id

    left join customers
        on customers.customer_id = charges.customer_id

    {% if var('recharge__checkout_enabled', false) %}
    left join checkouts
        on checkouts.charge_id = charges.charge_id
    {% endif %}

    left join charge_shipping_lines
        on charge_shipping_lines.charge_id = charges.charge_id

    left join subscriptions
        on subscriptions.subscription_id = charge_line_items.purchase_item_id

), final as (

    -- line item level
    select 
        header_id,
        line_item_id,
        line_item_index,
        'line_item' as record_type,
        created_at,
        currency,
        header_status,
        product_id,
        product_name,
        transaction_type,
        billing_type,
        product_type,
        quantity,
        unit_amount,
        cast(null as {{ dbt.type_numeric() }}) as discount_amount,
        tax_amount,
        total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        cast(null as {{ dbt.type_numeric() }}) as fee_amount,
        cast(null as {{ dbt.type_numeric() }}) as refund_amount,
        subscription_id,
        subscription_plan,
        subscription_period_started_at,
        subscription_period_ended_at,
        subscription_status,
        customer_id,
        customer_created_at,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced

    union all

    -- header level
    select
        header_id,
        cast(null as {{ dbt.type_string() }}) as line_item_id,
        cast(0 as {{ dbt.type_int() }}) as line_item_index,
        'header' as record_type,
        created_at,
        currency,
        header_status,
        cast(null as {{ dbt.type_string() }}) as product_id,
        cast(null as {{ dbt.type_string() }}) as product_name,
        cast(null as {{ dbt.type_string() }}) as transaction_type,
        billing_type,
        cast(null as {{ dbt.type_string() }}) as product_type,
        cast(null as {{ dbt.type_int() }}) as quantity,
        cast(null as {{ dbt.type_numeric() }}) as unit_amount,
        discount_amount,
        cast(null as {{ dbt.type_numeric() }}) as tax_amount,
        cast(null as {{ dbt.type_numeric() }}) as total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        fee_amount,
        refund_amount,
        cast(null as {{ dbt.type_string() }}) as subscription_id,
        cast(null as {{ dbt.type_string() }}) as subscription_plan,
        cast(null as {{ dbt.type_timestamp() }}) as subscription_period_started_at,
        cast(null as {{ dbt.type_timestamp() }}) as subscription_period_ended_at,
        cast(null as {{ dbt.type_string() }}) as subscription_status,
        customer_id,
        customer_created_at,
        customer_level,
        customer_name,
        customer_company,
        customer_email,
        customer_city,
        customer_country
    from enhanced
    where line_item_index = 1
)

select *
from final