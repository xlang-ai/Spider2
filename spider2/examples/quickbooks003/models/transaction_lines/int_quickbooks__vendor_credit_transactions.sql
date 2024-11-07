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

    select *
    from {{ ref('stg_quickbooks__item') }}
),

final as (

    select
        cast(vendor_credits.vendor_credit_id as {{ dbt.type_string() }}) as transaction_id,
        vendor_credits.source_relation,
        vendor_credit_lines.index as transaction_line_id,
        vendor_credits.doc_number,
        'vendor_credit' as transaction_type,
        vendor_credits.transaction_date,
        
        -- Explicit type casting to string to ensure type consistency
        cast(
            coalesce(
                cast(vendor_credit_lines.account_expense_account_id as {{ dbt.type_string() }}), 
                cast(items.expense_account_id as {{ dbt.type_string() }})
            ) as {{ dbt.type_string() }}
        ) as account_id,
        
        cast(
            coalesce(
                cast(vendor_credit_lines.account_expense_class_id as {{ dbt.type_string() }}), 
                cast(vendor_credit_lines.item_expense_class_id as {{ dbt.type_string() }})
            ) as {{ dbt.type_string() }}
        ) as class_id,
        
        cast(vendor_credits.department_id as {{ dbt.type_string() }}) as department_id,
        
        cast(
            coalesce(
                cast(vendor_credit_lines.account_expense_customer_id as {{ dbt.type_string() }}), 
                cast(vendor_credit_lines.item_expense_customer_id as {{ dbt.type_string() }})
            ) as {{ dbt.type_string() }}
        ) as customer_id,
        
        cast(vendor_credits.vendor_id as {{ dbt.type_string() }}) as vendor_id,
        
        coalesce(
            cast(vendor_credit_lines.account_expense_billable_status as {{ dbt.type_string() }}), 
            cast(vendor_credit_lines.item_expense_billable_status as {{ dbt.type_string() }})
        ) as billable_status,
        
        vendor_credit_lines.description,
        
        -- Correct type handling for negative amounts
        vendor_credit_lines.amount * -1 as amount,
        vendor_credit_lines.amount * coalesce(-vendor_credits.exchange_rate, -1) as converted_amount,
        
        vendor_credits.total_amount * -1 as total_amount,
        vendor_credits.total_amount * coalesce(-vendor_credits.exchange_rate, -1) as total_converted_amount
        
    from vendor_credits

    inner join vendor_credit_lines
        on vendor_credits.vendor_credit_id = vendor_credit_lines.vendor_credit_id
        and vendor_credits.source_relation = vendor_credit_lines.source_relation

    left join items
        on vendor_credit_lines.item_expense_item_id = items.item_id
        and vendor_credit_lines.source_relation = items.source_relation
)

select *
from final
