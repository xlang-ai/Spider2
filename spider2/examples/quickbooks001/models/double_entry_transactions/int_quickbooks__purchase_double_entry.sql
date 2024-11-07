/*
Table that creates a debit record to a specified expense account and a credit record to the payment account.
*/
with purchases as (

    select *
    from {{ ref('stg_quickbooks__purchase') }}
),

purchase_lines as (

    select *
    from {{ ref('stg_quickbooks__purchase_line') }}
),

items as (

    select
        item.*,
        parent.expense_account_id as parent_expense_account_id
    from {{ ref('stg_quickbooks__item') }} item

    left join {{ ref('stg_quickbooks__item') }} parent
        on item.parent_item_id = parent.item_id
        and item.source_relation = parent.source_relation
),

purchase_join as (

    select
        purchases.purchase_id as transaction_id,
        purchases.source_relation,
        purchase_lines.index,
        purchases.transaction_date,
        purchase_lines.amount,
        (purchase_lines.amount * coalesce(purchases.exchange_rate, 1)) as converted_amount,
        coalesce(purchase_lines.account_expense_account_id, items.parent_expense_account_id, items.expense_account_id) as payed_to_account_id,
        purchases.account_id as payed_from_account_id,
        case when coalesce(purchases.credit, false) = true then 'debit' else 'credit' end as payed_from_transaction_type,
        case when coalesce(purchases.credit, false) = true then 'credit' else 'debit' end as payed_to_transaction_type,
        purchases.customer_id,
        coalesce(purchase_lines.item_expense_class_id, purchase_lines.account_expense_class_id) as class_id,
        purchases.vendor_id,
        purchases.department_id
    from purchases

    inner join purchase_lines
        on purchases.purchase_id = purchase_lines.purchase_id
        and purchases.source_relation = purchase_lines.source_relation

    left join items
        on purchase_lines.item_expense_item_id = items.item_id
        and purchase_lines.source_relation = items.source_relation
),

final as (

    select
        transaction_id,
        source_relation,
        index,
        transaction_date,
        customer_id,
        vendor_id,
        amount,
        converted_amount,
        payed_from_account_id as account_id,
        class_id,
        department_id,
        payed_from_transaction_type as transaction_type,
        'purchase' as transaction_source
    from purchase_join

    union all

    select
        transaction_id,
        source_relation,
        index,
        transaction_date,
        customer_id,
        vendor_id,
        amount,
        converted_amount,
        payed_to_account_id as account_id,
        class_id,
        department_id,
        payed_to_transaction_type as transaction_type,
        'purchase' as transaction_source
    from purchase_join
)

select *
from final
