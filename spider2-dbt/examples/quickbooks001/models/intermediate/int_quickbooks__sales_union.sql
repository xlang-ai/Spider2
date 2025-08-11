{{ config(enabled=fivetran_utils.enabled_vars_one_true(['using_sales_receipt','using_invoice'])) }}

with sales_union as (

    {% if var('using_sales_receipt', True) %}
    select *
    from {{ ref('int_quickbooks__sales_receipt_transactions') }}
    {% endif %}

    {% if fivetran_utils.enabled_vars(['using_sales_receipt','using_invoice']) %}
    union all

    select *
    from {{ ref('int_quickbooks__invoice_transactions') }}

    {% else %}

        {% if var('using_invoice', True) %}
        select *
        from {{ ref('int_quickbooks__invoice_transactions') }}
        {% endif %}   
        
    {% endif %}

    {% if var('using_refund_receipt', True) %}
    union all

    select *
    from {{ ref('int_quickbooks__refund_receipt_transactions') }}
    {% endif %}

    {% if var('using_credit_memo', True) %}
    union all

    select *
    from {{ ref('int_quickbooks__credit_memo_transactions') }}
    {% endif %}
),

customers as (

    select *
    from {{ ref('stg_quickbooks__customer') }}
),

{% if var('using_department', True) %}
departments as ( 

    select *
    from {{ ref('stg_quickbooks__department') }}
),
{% endif %}

vendors as (

    select *
    from {{ ref('stg_quickbooks__vendor') }}
),

income_accounts as (

    select *
    from {{ ref('int_quickbooks__account_classifications') }}
    where account_type = 'Income'
),

final as (

    select 
        'sales' as transaction_source,
        sales_union.transaction_id,
        sales_union.source_relation,
        sales_union.transaction_line_id,
        sales_union.doc_number,
        sales_union.transaction_type,
        sales_union.transaction_date,
        sales_union.item_id,
        sales_union.item_quantity,
        sales_union.item_unit_price,
        sales_union.account_id,
        income_accounts.name as account_name,
        income_accounts.account_sub_type as account_sub_type,
        sales_union.class_id,
        sales_union.department_id,
        {% if var('using_department', True) %}
        departments.fully_qualified_name as department_name,
        {% endif %}
        sales_union.customer_id,
        customers.fully_qualified_name as customer_name,
        customers.website as customer_website,
        sales_union.vendor_id,
        vendors.display_name as vendor_name,
        sales_union.billable_status,
        sales_union.description,
        sales_union.amount,
        sales_union.converted_amount,
        sales_union.total_amount,
        sales_union.total_converted_amount
    from sales_union

    inner join income_accounts
        on sales_union.account_id = income_accounts.account_id
        and sales_union.source_relation = income_accounts.source_relation

    left join customers
        on customers.customer_id = sales_union.customer_id
        and customers.source_relation = sales_union.source_relation

    left join vendors
        on vendors.vendor_id = sales_union.vendor_id
        and vendors.source_relation = sales_union.source_relation

    {% if var('using_department', True) %}
    left join departments
        on departments.department_id = sales_union.department_id
        and departments.source_relation = sales_union.source_relation
    {% endif %}
)

select *
from final