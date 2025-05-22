with accounts as (

    select *
    from {{ ref('stg_quickbooks__account') }}
),

classification_fix as (

    select 
        account_id,
        source_relation,
        account_number,
        is_sub_account,
        parent_account_id,
        name,
        account_type,
        account_sub_type,
        balance,
        balance_with_sub_accounts,
        is_active,
        created_at,
        currency_id,
        description,
        fully_qualified_name,
        updated_at,
        case when classification is not null
            then classification
            when classification is null and account_type in ('Bank', 'Other Current Asset', 'Fixed Asset', 'Other Asset', 'Accounts Receivable')
                then 'Asset'
            when classification is null and account_type = 'Equity'
                then 'Equity'
            when classification is null and account_type in ('Expense', 'Other Expense', 'Cost of Goods Sold')
                then 'Expense'
            when classification is null and account_type in ('Accounts Payable', 'Credit Card', 'Long Term Liability', 'Other Current Liability')
                then 'Liability'
            when classification is null and account_type in ('Income', 'Other Income')
                then 'Revenue'
                    end as classification
    from accounts
),

classification_add as (

    select
        *,
        case when classification in ('Liability', 'Equity')
            then -1
        when classification = 'Asset'
            then 1
            else null
                end as multiplier,
        case when classification in ('Asset', 'Liability', 'Equity')
            then 'balance_sheet'
            else 'income_statement'
                end as financial_statement_helper,
        case when classification in ('Asset', 'Expense')
            then 'debit'
            else 'credit'
                end as transaction_type
    from classification_fix
),

adjusted_balances as (

    select 
        *,
        (balance * multiplier) as adjusted_balance
    from classification_add
),

final as (

    select
        adjusted_balances.*,
        case when adjusted_balances.is_sub_account
            then parent_accounts.account_number
            else adjusted_balances.account_number
                end as parent_account_number,
        case when adjusted_balances.is_sub_account
            then parent_accounts.fully_qualified_name
            else adjusted_balances.fully_qualified_name
                end as parent_account_name
    from adjusted_balances

    left join accounts as parent_accounts
        on parent_accounts.account_id = adjusted_balances.parent_account_id
        and parent_accounts.source_relation = adjusted_balances.source_relation
)

select *
from final
