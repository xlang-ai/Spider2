--To disable this model, set the using_sales_receipt variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_sales_receipt', True)) }}

with sales_receipts as (

    select *
    from {{ ref('stg_quickbooks__sales_receipt') }}
),

sales_receipt_lines as (

    select *
    from {{ ref('stg_quickbooks__sales_receipt_line') }}
),

items as (

    select *
    from {{ ref('stg_quickbooks__item') }}
),

final as (

    select
        sales_receipts.sales_receipt_id as transaction_id,
        sales_receipts.source_relation,
        sales_receipt_lines.index as transaction_line_id,
        sales_receipts.doc_number,
        'sales_receipt' as transaction_type,
        sales_receipts.transaction_date,
        sales_receipt_lines.sales_item_item_id as item_id,
        sales_receipt_lines.sales_item_quantity as item_quantity,
        sales_receipt_lines.sales_item_unit_price as item_unit_price,
        coalesce(items.income_account_id, items.asset_account_id, items.expense_account_id) as account_id,
        sales_receipts.class_id,
        sales_receipts.department_id,
        sales_receipts.customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        cast(null as {{ dbt.type_string() }}) as billable_status,
        sales_receipt_lines.description,
        sales_receipt_lines.amount,
        sales_receipt_lines.amount * (coalesce(sales_receipts.exchange_rate, 1)) as converted_amount,
        sales_receipts.total_amount,
        sales_receipts.total_amount * (coalesce(sales_receipts.exchange_rate, 1)) as total_converted_amount
    from sales_receipts

    inner join sales_receipt_lines
        on sales_receipts.sales_receipt_id = sales_receipt_lines.sales_receipt_id   
        and sales_receipts.source_relation = sales_receipt_lines.source_relation

    left join items
        on sales_receipt_lines.sales_item_item_id = items.item_id
        and sales_receipt_lines.source_relation = items.source_relation
)

select *
from final