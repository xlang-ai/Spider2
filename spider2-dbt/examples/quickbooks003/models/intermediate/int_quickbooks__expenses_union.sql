with expense_union as (

    select *
    from {{ ref('int_quickbooks__purchase_transactions') }}

    {% if var('using_bill', True) %}
    union all

    select *
    from {{ ref('int_quickbooks__bill_transactions') }}
    {% endif %} 

    {% if var('using_journal_entry', True) %}
    union all

    select *
    from {{ ref('int_quickbooks__journal_entry_transactions')}}
    {% endif %} 

    {% if var('using_deposit', True) %}
    union all

    select *
    from {{ ref('int_quickbooks__deposit_transactions')}}
    {% endif %} 

    {% if var('using_vendor_credit', True) %}
    union all

    select *
    from {{ ref('int_quickbooks__vendor_credit_transactions') }}
    {% endif %}
),

customers as (

    select *
    from {{ ref('stg_quickbooks__customer') }}
),

{% if var('using_department', True) %}
departments as ( 

    select *
    from {{ ref('stg_quickbooks__department') }}
),
{% endif %}

vendors as (

    select *
    from {{ ref('stg_quickbooks__vendor') }}
),

expense_accounts as (

    select *
    from {{ ref('int_quickbooks__account_classifications') }}
    where account_type = 'Expense'
),

final as (

    select 
        'expense' as transaction_source,
        expense_union.transaction_id,
        expense_union.source_relation,
        expense_union.transaction_line_id,
        expense_union.doc_number,
        expense_union.transaction_type,
        expense_union.transaction_date,
        cast(null as {{ dbt.type_string() }}) as item_id,
        cast(null as {{ dbt.type_numeric() }}) as item_quantity,
        cast(null as {{ dbt.type_numeric() }}) as item_unit_price,
        expense_union.account_id,
        expense_accounts.name as account_name,
        expense_accounts.account_sub_type as account_sub_type,
        expense_union.class_id,
        expense_union.department_id,
        {% if var('using_department', True) %}
        departments.fully_qualified_name as department_name,
        {% endif %}
        expense_union.customer_id,
        customers.fully_qualified_name as customer_name,
        customers.website as customer_website,
        expense_union.vendor_id,
        vendors.display_name as vendor_name,
        expense_union.billable_status,
        expense_union.description,
        expense_union.amount,
        expense_union.converted_amount,
        expense_union.total_amount,
        expense_union.total_converted_amount

    from expense_union

    inner join expense_accounts
        on expense_union.account_id = expense_accounts.account_id
        and expense_union.source_relation = expense_accounts.source_relation

    left join customers
        on customers.customer_id = expense_union.customer_id
        and customers.source_relation = expense_union.source_relation

    left join vendors
        on vendors.vendor_id = expense_union.vendor_id
        and vendors.source_relation = expense_union.source_relation

    {% if var('using_department', True) %}
    left join departments
        on departments.department_id = expense_union.department_id
        and departments.source_relation = expense_union.source_relation
    {% endif %}
)

select *
from final