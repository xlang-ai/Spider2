/*
Table that creates a debit record to the specified asset account and a credit record the specified cash account.
*/

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

    select
        item.*,
        parent.income_account_id as parent_income_account_id
    from {{ ref('stg_quickbooks__item') }} item

    left join {{ ref('stg_quickbooks__item') }} parent
        on item.parent_item_id = parent.item_id
        and item.source_relation = parent.source_relation
),

refund_receipt_join as (

    select
        refund_receipts.refund_id as transaction_id,
        refund_receipts.source_relation,
        refund_receipt_lines.index,
        refund_receipts.transaction_date,
        refund_receipt_lines.amount,
        (refund_receipt_lines.amount * coalesce(refund_receipts.exchange_rate, 1)) as converted_amount,
        refund_receipts.deposit_to_account_id as credit_to_account_id,
        coalesce(refund_receipt_lines.discount_account_id, refund_receipt_lines.sales_item_account_id, items.parent_income_account_id, items.income_account_id) as debit_account_id,
        refund_receipts.customer_id,
        coalesce(refund_receipt_lines.sales_item_class_id, refund_receipt_lines.discount_class_id, refund_receipts.class_id) as class_id,
        refund_receipts.department_id
    from refund_receipts

    inner join refund_receipt_lines
        on refund_receipts.refund_id = refund_receipt_lines.refund_id
        and refund_receipts.source_relation = refund_receipt_lines.source_relation

    left join items
        on refund_receipt_lines.sales_item_item_id = items.item_id
        and refund_receipt_lines.source_relation = items.source_relation

    where coalesce(refund_receipt_lines.discount_account_id, refund_receipt_lines.sales_item_account_id, refund_receipt_lines.sales_item_item_id) is not null
),

final as (

    select
        transaction_id,
        source_relation,
        index,
        transaction_date,
        customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        amount,
        converted_amount,
        credit_to_account_id as account_id,
        class_id,
        department_id,
        'credit' as transaction_type,
        'refund_receipt' as transaction_source
    from refund_receipt_join

    union all

    select
        transaction_id,
        source_relation,
        index,
        transaction_date,
        customer_id,
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        amount,
        converted_amount,
        debit_account_id as account_id,
        class_id,
        department_id,
        'debit' as transaction_type,
        'refund_receipt' as transaction_source
    from refund_receipt_join
)

select *
from final
