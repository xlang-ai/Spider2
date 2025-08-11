--To disable this model, set the using_purchase variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_purchase', True)) }}

with purchases as (
    select *
    from {{ ref('stg_quickbooks__purchase') }}
),

items as (
    select *
    from {{ ref('stg_quickbooks__item') }}
),

purchase_lines as (
    select *
    from {{ ref('stg_quickbooks__purchase_line') }}
),

final as (
    select
        purchases.purchase_id as transaction_id,
        purchases.source_relation,
        purchase_lines.index as transaction_line_id,
        purchases.doc_number,
        'purchase' as transaction_type,
        purchases.transaction_date,
        coalesce(
            cast(purchase_lines.account_expense_account_id as {{ dbt.type_string() }}), 
            cast(items.expense_account_id as {{ dbt.type_string() }})
        ) as account_id,
        cast(purchase_lines.account_expense_class_id as {{ dbt.type_string() }}) as class_id,
        purchases.department_id,
        coalesce(
            cast(purchases.customer_id as {{ dbt.type_string() }}), 
            cast(purchase_lines.account_expense_customer_id as {{ dbt.type_string() }}), 
            cast(purchase_lines.item_expense_customer_id as {{ dbt.type_string() }})
        ) as customer_id,
        purchases.vendor_id,
        coalesce(
            cast(purchase_lines.account_expense_billable_status as {{ dbt.type_string() }}), 
            cast(purchase_lines.item_expense_billable_status as {{ dbt.type_string() }})
        ) as billable_status,
        purchase_lines.description,
        case when coalesce(purchases.credit, false)
            then -1 * purchase_lines.amount
            else purchase_lines.amount
        end as amount,
        case when coalesce(purchases.credit, false)
            then purchase_lines.amount * coalesce(-purchases.exchange_rate, -1)
            else purchase_lines.amount * coalesce(purchases.exchange_rate, 1)
        end as converted_amount,
        case when coalesce(purchases.credit, false) 
            then -1 * purchases.total_amount
            else purchases.total_amount
        end as total_amount,
        case when coalesce(purchases.credit, false) 
            then purchases.total_amount * coalesce(-purchases.exchange_rate, -1)
            else purchases.total_amount * coalesce(purchases.exchange_rate, 1)
        end as total_converted_amount
    from purchases

    inner join purchase_lines 
        on purchases.purchase_id = purchase_lines.purchase_id
        and purchases.source_relation = purchase_lines.source_relation

    left join items
        on purchase_lines.item_expense_item_id = items.item_id
        and purchase_lines.source_relation = items.source_relation
)

select *
from final
