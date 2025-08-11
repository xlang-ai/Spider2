/*
Table that creates a debit record to payable account and a credit record to the expense account.
*/

--To disable this model, set the using_vendor_credit variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_vendor_credit', True)) }}

with vendor_credits as (

    select *
    from {{ ref('stg_quickbooks__vendor_credit') }}
),

vendor_credit_lines as (

    select *
    from {{ ref('stg_quickbooks__vendor_credit_line') }}
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

vendor_credit_join as (

    select
        vendor_credits.vendor_credit_id as transaction_id,
        vendor_credits.source_relation,
        vendor_credit_lines.index,
        vendor_credits.transaction_date,
        vendor_credit_lines.amount,
        (vendor_credit_lines.amount * coalesce(vendor_credits.exchange_rate, 1)) as converted_amount,
        vendor_credits.payable_account_id as debit_to_account_id,
        coalesce(vendor_credit_lines.account_expense_account_id, items.parent_income_account_id, items.income_account_id, items.expense_account_id) as credit_account_id,
        coalesce(account_expense_customer_id, item_expense_customer_id) as customer_id,
        coalesce(item_expense_class_id, account_expense_class_id) as class_id,
        vendor_credits.vendor_id,
        vendor_credits.department_id
    from vendor_credits

    inner join vendor_credit_lines
        on vendor_credits.vendor_credit_id = vendor_credit_lines.vendor_credit_id
        and vendor_credits.source_relation = vendor_credit_lines.source_relation

    left join items
        on vendor_credit_lines.item_expense_item_id = items.item_id
        and vendor_credit_lines.source_relation = items.source_relation
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
        credit_account_id as account_id,
        class_id,
        department_id,
        'credit' as transaction_type,
        'vendor_credit' as transaction_source
    from vendor_credit_join

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
        debit_to_account_id as account_id,
        class_id,
        department_id,
        'debit' as transaction_type,
        'vendor_credit' as transaction_source
    from vendor_credit_join
)

select *
from final
