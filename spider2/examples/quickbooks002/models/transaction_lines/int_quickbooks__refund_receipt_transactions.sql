--To disable this model, set the using_refund_receipt variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_refund_receipt', True)) }}

with refund_receipts as (

    select *
    from {{ ref('stg_quickbooks__refund_receipt') }}
),

refund_receipt_lines as (

    select *
    from {{ ref('stg_quickbooks__refund_receipt_line') }}
),

items as (

    select *
    from {{ ref('stg_quickbooks__item') }}
),

final as (

    select
        refund_receipts.refund_id as transaction_id,
        refund_receipts.source_relation,
        refund_receipt_lines.index as transaction_line_id,
        refund_receipts.doc_number,
        'refund_receipt' as transaction_type,
        refund_receipts.transaction_date,
        refund_receipt_lines.sales_item_item_id as item_id,
        refund_receipt_lines.sales_item_quantity as item_quantity,
        refund_receipt_lines.sales_item_unit_price as item_unit_price,
        case when refund_receipt_lines.sales_item_account_id is null
            then coalesce(items.asset_account_id, items.income_account_id, items.expense_account_id) 
            else refund_receipt_lines.sales_item_account_id
                end as account_id,
        refund_receipts.class_id,
        refund_receipts.department_id,
        refund_receipts.customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        cast(null as {{ dbt.type_string() }}) as billable_status,
        refund_receipt_lines.description,
        refund_receipt_lines.amount * -1 as amount,
        refund_receipt_lines.amount * coalesce(-refund_receipts.exchange_rate, -1) as converted_amount,
        refund_receipts.total_amount * -1 as total_amount,
        refund_receipts.total_amount * coalesce(-refund_receipts.exchange_rate, -1) as total_converted_amount
    from refund_receipts

    inner join refund_receipt_lines
        on refund_receipts.refund_id = refund_receipt_lines.refund_id
        and refund_receipts.source_relation = refund_receipt_lines.source_relation

    left join items
        on refund_receipt_lines.sales_item_item_id = items.item_id
        and refund_receipt_lines.source_relation = items.source_relation
)

select *
from final