--To disable this model, set the using_bill and using_invoice variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_bill', True) and var('using_invoice', True) and var('using_payment', True)) }}

with bill_join as (

    select *
    from {{ref('int_quickbooks__bill_join')}}
),

{% if var('using_invoice', True) %}
invoice_join as (

    select *
    from {{ref('int_quickbooks__invoice_join')}}
),
{% endif %}

{% if var('using_department', True) %}
departments as ( 

    select *
    from {{ ref('stg_quickbooks__department') }}
),
{% endif %}

{% if var('using_address', True) %}
addresses as (

    select *
    from {{ref('stg_quickbooks__address')}}
),
{% endif %}

customers as (

    select *
    from {{ ref('stg_quickbooks__customer') }}
),

vendors as (

    select *
    from {{ ref('stg_quickbooks__vendor') }}
),

final as (

    select
        bill_join.transaction_type,
        bill_join.transaction_id,
        bill_join.source_relation,
        doc_number,
        cast(null as {{ dbt.type_string() }}) as estimate_id, 

        {% if var('using_department', True) %}
        departments.fully_qualified_name as department_name,
        {% endif %}

        'vendor' as transaction_with,
        vendors.display_name as customer_vendor_name,
        vendors.balance as customer_vendor_balance,

        {% if var('using_address', True) %}
        billing_address.city as customer_vendor_address_city,
        billing_address.country as customer_vendor_address_country,
        concat(billing_address.address_1, billing_address.address_2) as customer_vendor_address_line,
        {% endif %}
        
        vendors.web_url as customer_vendor_website,
        cast(null as {{ dbt.type_string() }}) as delivery_type,
        cast(null as {{ dbt.type_string() }}) as estimate_status,
        bill_join.total_amount,
        bill_join.total_converted_amount,
        cast(null as {{ dbt.type_numeric() }}) as estimate_total_amount,
        cast(null as {{ dbt.type_numeric() }}) as estimate_total_converted_amount,
        bill_join.current_balance,
        bill_join.due_date,
        case when bill_join.current_balance != 0 and {{ dbt.datediff("bill_join.recent_payment_date", "bill_join.due_date", 'day') }} < 0
            then true
            else false
                end as is_overdue,
        case when bill_join.current_balance != 0 and {{ dbt.datediff("bill_join.recent_payment_date", "bill_join.due_date", 'day') }} < 0
            then {{ dbt.datediff("bill_join.recent_payment_date", "bill_join.due_date", 'day') }} * -1
            else 0
                end as days_overdue,
        bill_join.initial_payment_date,
        bill_join.recent_payment_date,
        bill_join.total_current_payment,
        bill_join.total_current_converted_payment
    from bill_join

    {% if var('using_department', True) %}
    left join departments  
        on bill_join.department_id = departments.department_id
        and bill_join.source_relation = departments.source_relation
    {% endif %}

    left join vendors
        on bill_join.vendor_id = vendors.vendor_id
        and bill_join.source_relation = vendors.source_relation
    
    {% if var('using_address', True) %}
    left join addresses as billing_address
        on vendors.billing_address_id = billing_address.address_id
        and vendors.source_relation = billing_address.source_relation
    {% endif %}
    
    {% if var('using_invoice', True) %}
    union all

    select 
        invoice_join.transaction_type,
        invoice_join.transaction_id,
        invoice_join.source_relation,
        doc_number,
        invoice_join.estimate_id,

        {% if var('using_department', True) %}
        departments.fully_qualified_name as department_name,
        {% endif %}

        'customer' as transaction_with,
        customers.fully_qualified_name as customer_vendor_name,
        customers.balance as customer_vendor_current_balance,

        {% if var('using_address', True) %}
        billing_address.city as customer_vendor_address_city,
        billing_address.country as customer_vendor_address_country,
        concat(billing_address.address_1, billing_address.address_2) as customer_vendor_address_line,
        {% endif %}

        customers.website as customer_vendor_website,
        invoice_join.delivery_type,
        invoice_join.estimate_status,
        invoice_join.total_amount as total_amount,
        invoice_join.total_converted_amount,
        invoice_join.estimate_total_amount as estimate_total_amount,
        invoice_join.estimate_total_converted_amount as estimate_total_converted_amount,
        invoice_join.current_balance as current_balance,
        invoice_join.due_date,
        case when invoice_join.current_balance != 0 and {{ dbt.datediff("invoice_join.recent_payment_date", "invoice_join.due_date", 'day') }} < 0
            then true
            else false
                end as is_overdue,
        case when invoice_join.current_balance != 0 and {{ dbt.datediff("invoice_join.recent_payment_date", "invoice_join.due_date", 'day') }} < 0
            then {{ dbt.datediff("invoice_join.recent_payment_date", "invoice_join.due_date", 'day') }} * -1
            else 0
                end as days_overdue,
        invoice_join.initial_payment_date,
        invoice_join.recent_payment_date,
        invoice_join.total_current_payment as total_current_payment,
        invoice_join.total_current_converted_payment

    from invoice_join

    {% if var('using_department', True) %}
    left join departments  
        on invoice_join.department_id = departments.department_id
        and invoice_join.source_relation = departments.source_relation
    {% endif %}

    {% if var('using_address', True) %}
    left join addresses as billing_address
        on invoice_join.billing_address_id = billing_address.address_id
        and invoice_join.source_relation = billing_address.source_relation
    {% endif %}

    left join customers
        on invoice_join.customer_id = customers.customer_id
        and invoice_join.source_relation = customers.source_relation

    {% endif %}
)

select * 
from final