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

    select *
    from {{ ref('stg_quickbooks__item') }}
),

final as (

    select
        invoices.invoice_id as transaction_id,
        invoices.source_relation,
        invoice_lines.index as transaction_line_id,
        invoices.doc_number,
        'invoice' as transaction_type,
        invoices.transaction_date,
        coalesce(invoice_lines.sales_item_item_id, invoice_lines.item_id) as item_id,
        coalesce(invoice_lines.quantity, invoice_lines.sales_item_quantity) as item_quantity,
        invoice_lines.sales_item_unit_price as item_unit_price,
        case when invoice_lines.account_id is null
            then coalesce(items.income_account_id, items.expense_account_id, items.asset_account_id)
            else invoice_lines.account_id
                end as account_id,
        coalesce(invoice_lines.discount_class_id, invoice_lines.sales_item_class_id) as class_id,
        invoices.department_id,
        invoices.customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        cast(null as {{ dbt.type_string() }}) as billable_status,
        invoice_lines.description,
        invoice_lines.amount,
        invoice_lines.amount * coalesce(invoices.exchange_rate, 1) as converted_amount,
        invoices.total_amount,
        invoices.total_amount * coalesce(invoices.exchange_rate, 1) as total_converted_amount
    from invoices

    inner join invoice_lines
        on invoices.invoice_id = invoice_lines.invoice_id
        and invoices.source_relation = invoice_lines.source_relation

    left join items
        on coalesce(invoice_lines.sales_item_item_id, invoice_lines.item_id) = items.item_id
        and invoice_lines.source_relation = items.source_relation
)

select *
from final