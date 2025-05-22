/*
Table that creates a debit record to accounts receivable and a credit record to a specified revenue account indicated on the invoice line.
*/

--To disable this model, set the using_invoice variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_invoice', True)) }}

with invoices as (
    select *
    from {{ ref('stg_quickbooks__invoice') }}
),

invoice_lines as (
    select *
    from {{ ref('stg_quickbooks__invoice_line') }}
),

items as (
    select
        item.*,
        parent.income_account_id as parent_income_account_id
    from {{ ref('stg_quickbooks__item') }} item

    left join {{ ref('stg_quickbooks__item') }} parent
        on item.parent_item_id = parent.item_id
        and item.source_relation = parent.source_relation
),

accounts as (
    select *
    from {{ ref('stg_quickbooks__account') }}
),


{% if var('using_invoice_bundle', True) %}

invoice_bundles as (

    select *
    from {{ ref('stg_quickbooks__invoice_line_bundle') }}
),

bundles as (

    select *
    from {{ ref('stg_quickbooks__bundle') }}
),

bundle_items as (

    select *
    from {{ ref('stg_quickbooks__bundle_item') }}
),

income_accounts as (

    select *
    from accounts

    where account_sub_type = '{{ var('quickbooks__sales_of_product_income_reference', 'SalesOfProductIncome') }}'
),

bundle_income_accounts as (

    select distinct
        coalesce(parent.income_account_id, income_accounts.account_id) as account_id,
        coalesce(parent.source_relation, income_accounts.source_relation) as source_relation,
        bundle_items.bundle_id

    from items

    left join items as parent
        on items.parent_item_id = parent.item_id
        and items.source_relation = parent.source_relation

    inner join income_accounts
        on income_accounts.account_id = items.income_account_id
        and income_accounts.source_relation = items.source_relation

    inner join bundle_items
        on bundle_items.item_id = items.item_id
        and bundle_items.source_relation = items.source_relation
),
{% endif %}

ar_accounts as (

    select 
        account_id,
        source_relation
    from accounts

    where account_type = '{{ var('quickbooks__accounts_receivable_reference', 'Accounts Receivable') }}'
        and is_active
        and not is_sub_account
),

invoice_join as (

    select
        invoices.invoice_id as transaction_id,
        invoices.source_relation,
        invoice_lines.index,
        invoices.transaction_date as transaction_date,

        {% if var('using_invoice_bundle', True) %}
        case when invoice_lines.bundle_id is not null and invoices.total_amount = 0 then invoices.total_amount
            else invoice_lines.amount
        end as amount,
        case when invoice_lines.bundle_id is not null and invoices.total_amount = 0 
            then (invoices.total_amount * coalesce(invoices.exchange_rate, 1))
            else (invoice_lines.amount * coalesce(invoices.exchange_rate, 1))
        end as converted_amount,
        case when invoice_lines.detail_type is not null then invoice_lines.detail_type
            when coalesce(invoice_lines.account_id, items.parent_income_account_id, items.income_account_id, bundle_income_accounts.account_id, invoice_lines.sales_item_account_id) is not null then 'SalesItemLineDetail'
            when invoice_lines.discount_account_id is not null then 'DiscountLineDetail'
            when coalesce(invoice_lines.account_id, items.parent_income_account_id, items.income_account_id, bundle_income_accounts.account_id, invoice_lines.discount_account_id, invoice_lines.sales_item_account_id) is null then 'NoAccountMapping'
        end as invoice_line_transaction_type,
        coalesce(invoice_lines.account_id, items.parent_income_account_id, items.income_account_id, bundle_income_accounts.account_id, invoice_lines.discount_account_id, invoice_lines.sales_item_account_id) as account_id,

        {% else %}
        invoice_lines.amount as amount,
        (invoice_lines.amount * coalesce(invoices.exchange_rate, 1)) as converted_amount,
        case when invoice_lines.detail_type is not null then invoice_lines.detail_type
            when coalesce(invoice_lines.account_id, items.parent_income_account_id, items.income_account_id, invoice_lines.sales_item_account_id) is not null then 'SalesItemLineDetail'
            when invoice_lines.discount_account_id is not null then 'DiscountLineDetail'
            when coalesce(invoice_lines.account_id, items.parent_income_account_id, items.income_account_id, invoice_lines.discount_account_id, invoice_lines.sales_item_account_id) is null then 'NoAccountMapping'
        end as invoice_line_transaction_type,
        coalesce(invoice_lines.account_id, items.income_account_id, invoice_lines.discount_account_id, invoice_lines.sales_item_account_id) as account_id,
        {% endif %}

        coalesce(invoice_lines.sales_item_class_id, invoice_lines.discount_class_id, invoices.class_id) as class_id,

        invoices.customer_id,
        invoices.department_id

    from invoices

    inner join invoice_lines
        on invoices.invoice_id = invoice_lines.invoice_id
        and invoices.source_relation = invoice_lines.source_relation

    left join items
        on coalesce(invoice_lines.sales_item_item_id, invoice_lines.item_id) = items.item_id
        and invoice_lines.source_relation = items.source_relation

    {% if var('using_invoice_bundle', True) %}
    left join bundle_income_accounts
        on bundle_income_accounts.bundle_id = invoice_lines.bundle_id
        and bundle_income_accounts.source_relation = invoice_lines.source_relation

    {% endif %}
),

invoice_filter as (

    select *
    from invoice_join
    where invoice_line_transaction_type not in ('SubTotalLineDetail','NoAccountMapping')
),

final as (

    select
        transaction_id,
        invoice_filter.source_relation,
        index,
        transaction_date,
        customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        amount,
        converted_amount,
        account_id,
        class_id,
        department_id,
        case when invoice_line_transaction_type = 'DiscountLineDetail' then 'debit'
            else 'credit' 
        end as transaction_type,
        case when invoice_line_transaction_type = 'DiscountLineDetail' then 'invoice discount'
            else 'invoice'
        end as transaction_source
    from invoice_filter

    union all

    select
        transaction_id,
        invoice_filter.source_relation,
        index,
        transaction_date,
        customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        amount,
        converted_amount,
        ar_accounts.account_id,
        class_id,
        department_id,
        case when invoice_line_transaction_type = 'DiscountLineDetail' then 'credit'
            else 'debit' 
        end as transaction_type,
        case when invoice_line_transaction_type = 'DiscountLineDetail' then 'invoice discount'
            else 'invoice'
        end as transaction_source
    from invoice_filter

    left join ar_accounts
        on ar_accounts.source_relation = invoice_filter.source_relation
)

select *
from final
