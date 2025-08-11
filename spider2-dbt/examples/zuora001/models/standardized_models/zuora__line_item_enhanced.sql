{{ config(enabled= var('zuora__standardized_billing_model_enabled', False)) }}

with line_items as (

    select * 
    from {{ var('invoice_item')}}
    where is_most_recent_record 

), accounts as (

    select * 
    from {{ var('account') }}
    where is_most_recent_record 

), contacts as (

    select * 
    from {{ var('contact') }}
    where is_most_recent_record 

), invoices as (

    select * 
    from {{ var('invoice') }}
    where is_most_recent_record 

), invoice_payments as (

    select * 
    from {{ var('invoice_payment') }}
    where is_most_recent_record 

), payments as (

    select * 
    from {{ var('payment') }}
    where is_most_recent_record

), payment_methods as (

    select * 
    from {{ var('payment_method') }}
    where is_most_recent_record

), products as (

    select * 
    from {{ var('product') }}
    where is_most_recent_record

), subscriptions as (

    select *
    from {{ var('subscription') }} 
    where is_most_recent_record

), rate_plan as (

    select * 
    from {{ var('rate_plan') }}
    where is_most_recent_record 

), enhanced as (
select
    line_items.invoice_id as header_id,
    line_items.invoice_item_id as line_item_id,
    row_number() over (partition by line_items.invoice_id
        order by line_items.invoice_item_id) as line_item_index,
    line_items.created_date as line_item_created_at,
    invoices.created_date as invoice_created_at,
    invoices.status as header_status,
    invoices.source_type as billing_type,
    line_items.transaction_currency as currency,
    line_items.product_id,
    products.name as product_name,
    products.category as product_type,
    case 
        when cast(line_items.processing_type as {{ dbt.type_string() }}) = '0' then 'charge'
        when cast(line_items.processing_type as {{ dbt.type_string() }}) = '1' then 'discount'
        when cast(line_items.processing_type as {{ dbt.type_string() }}) = '2' then 'prepayment'
        when cast(line_items.processing_type as {{ dbt.type_string() }}) = '3' then 'tax'
        end as transaction_type,
    line_items.quantity,
    line_items.unit_price as unit_amount,
    case when cast(line_items.processing_type as {{ dbt.type_string() }}) = '1' 
        then line_items.charge_amount else 0 end as discount_amount,
    line_items.tax_amount,
    line_items.charge_amount as total_amount,
    invoice_payments.payment_id as payment_id,
    invoice_payments.payment_method_id,
    payment_methods.name as payment_method,
    payments.effective_date as payment_at,
    invoices.refund_amount,
    line_items.subscription_id,
    rate_plan.name as subscription_plan,
    subscriptions.subscription_start_date as subscription_period_started_at,
    subscriptions.subscription_end_date as subscription_period_ended_at,
    subscriptions.status as subscription_status,
    line_items.account_id as customer_id,
    'customer' as customer_level,
    accounts.created_date as customer_created_at,
    accounts.name as customer_company,
    {{ dbt.concat(["contacts.first_name", "' '", "contacts.last_name"]) }} as customer_name,
    contacts.work_email as customer_email,
    contacts.city as customer_city,
    contacts.country as customer_country

from line_items

left join invoices
    on invoices.invoice_id = line_items.invoice_id

left join invoice_payments
    on invoice_payments.invoice_id = invoices.invoice_id

left join payments
    on payments.payment_id = invoice_payments.payment_id

left join payment_methods
    on payment_methods.payment_method_id = payments.payment_method_id

left join accounts
    on accounts.account_id = line_items.account_id

left join contacts
    on contacts.contact_id = line_items.bill_to_contact_id

left join products
    on products.product_id = line_items.product_id

left join subscriptions
    on subscriptions.subscription_id = line_items.subscription_id

left join rate_plan
    on rate_plan.subscription_id = subscriptions.subscription_id


), final as (

    select 
        header_id,
        line_item_id,
        line_item_index,
        'line_item' as record_type,
        line_item_created_at as created_at,
        currency,
        header_status,
        product_id,
        product_name,
        transaction_type,
        billing_type,
        product_type,
        quantity,
        unit_amount,
        discount_amount,
        tax_amount,
        total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        cast(null as {{ dbt.type_float() }}) as fee_amount,
        cast(null as {{ dbt.type_float() }}) as refund_amount,
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

    -- Refund information is only reliable at the invoice header. Therefore the below operation creates a new line to track the refund values.
    select
        header_id,
        cast(null as {{ dbt.type_string() }}) as line_item_id,
        cast(0 as {{ dbt.type_int() }}) as line_item_index,
        'header' as record_type,
        invoice_created_at as created_at,
        currency,
        header_status,
        cast(null as {{ dbt.type_string() }}) as product_id,
        cast(null as {{ dbt.type_string() }}) as product_name,
        cast(null as {{ dbt.type_string() }}) as transaction_type,
        billing_type,
        cast(null as {{ dbt.type_string() }}) as product_type,
        cast(null as {{ dbt.type_float() }}) as quantity,
        cast(null as {{ dbt.type_float() }}) as unit_amount,
        cast(null as {{ dbt.type_float() }}) as discount_amount,
        cast(null as {{ dbt.type_float() }}) as tax_amount,
        cast(null as {{ dbt.type_float() }}) as total_amount,
        payment_id,
        payment_method_id,
        payment_method,
        payment_at,
        cast(null as {{ dbt.type_float() }}) as fee_amount,
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