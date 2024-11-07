--To disable this model, set the using_credit_memo variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_credit_memo', True)) }}

with credit_memos as (

    select *
    from {{ ref('stg_quickbooks__credit_memo') }}
),

credit_memo_lines as (

    select *
    from {{ ref('stg_quickbooks__credit_memo_line') }}
),

items as (

    select *
    from {{ ref('stg_quickbooks__item') }}
),

final as (

    select
        credit_memos.credit_memo_id as transaction_id,
        credit_memos.source_relation,
        credit_memo_lines.index as transaction_line_id,
        credit_memos.doc_number,
        'credit_memo' as transaction_type,
        credit_memos.transaction_date,
        credit_memo_lines.sales_item_item_id as item_id,
        credit_memo_lines.sales_item_quantity as item_quantity,
        credit_memo_lines.sales_item_unit_price as item_unit_price,
        case when credit_memo_lines.sales_item_account_id is null
            then coalesce(items.income_account_id, items.asset_account_id, items.expense_account_id) 
            else credit_memo_lines.sales_item_account_id
                end as account_id,
        credit_memos.class_id,
        credit_memos.department_id,
        credit_memos.customer_id, 
        cast(null as {{ dbt.type_string() }}) as vendor_id,
        cast(null as {{ dbt.type_string() }}) as billable_status,
        credit_memo_lines.description,
        credit_memo_lines.amount * -1 as amount,
        credit_memo_lines.amount * coalesce(-credit_memos.exchange_rate, -1) as converted_amount,
        credit_memos.total_amount * -1 as total_amount,
        credit_memos.total_amount * coalesce(-credit_memos.exchange_rate, -1) as total_converted_amount
    from credit_memos

    inner join credit_memo_lines
        on credit_memos.credit_memo_id = credit_memo_lines.credit_memo_id
        and credit_memos.source_relation = credit_memo_lines.source_relation

    left join items
        on credit_memo_lines.sales_item_item_id = items.item_id
        and credit_memo_lines.source_relation = items.source_relation
)

select *
from final