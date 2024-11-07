--To disable this model, set the using_bill variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_bill', True)) }}

with bills as (

    select *
    from {{ ref('stg_quickbooks__bill') }} 
),

bill_lines as (

    select *
    from {{ ref('stg_quickbooks__bill_line') }}
),

items as (

    select *
    from {{ ref('stg_quickbooks__item') }}
),

final as (

    select
        bills.bill_id as transaction_id,
        bills.source_relation,
        bill_lines.index as transaction_line_id,
        bills.doc_number,
        'bill' as transaction_type,
        bills.transaction_date,
        coalesce(
            cast(bill_lines.account_expense_account_id as {{ dbt.type_string() }}), 
            cast(items.expense_account_id as {{ dbt.type_string() }})
        ) as account_id,
        cast(bill_lines.account_expense_class_id as {{ dbt.type_string() }}) as class_id,
        bills.department_id,
        coalesce(
            cast(bill_lines.account_expense_customer_id as {{ dbt.type_string() }}), 
            cast(bill_lines.item_expense_customer_id as {{ dbt.type_string() }})
        ) as customer_id,
        bills.vendor_id,
        coalesce(
            cast(bill_lines.account_expense_billable_status as {{ dbt.type_string() }}), 
            cast(bill_lines.item_expense_billable_status as {{ dbt.type_string() }})
        ) as billable_status,
        coalesce(bill_lines.description, items.name) as description,
        bill_lines.amount,
        bill_lines.amount * coalesce(bills.exchange_rate, 1) as converted_amount,
        bills.total_amount,
        bills.total_amount * coalesce(bills.exchange_rate, 1) as total_converted_amount
    from bills

    inner join bill_lines 
        on bills.bill_id = bill_lines.bill_id
        and bills.source_relation = bill_lines.source_relation

    left join items
        on bill_lines.item_expense_item_id = items.item_id
        and bill_lines.source_relation = items.source_relation
)

select *
from final
