with general_ledger_balances as (

    select *
    from {{ ref('int_quickbooks__general_ledger_balances') }}
),

revenue_starter as (

    select
        period_first_day,
        source_relation,
        sum(period_net_change) as revenue_net_change,
        sum(period_net_converted_change) as revenue_net_converted_change
    from general_ledger_balances
    
    where account_class = 'Revenue'

    {{ dbt_utils.group_by(2) }} 
),

expense_starter as (

    select 
        period_first_day,
        source_relation,
        sum(period_net_change) as expense_net_change,
        sum(period_net_converted_change) as expense_net_converted_change
    from general_ledger_balances
    
    where account_class = 'Expense'

    {{ dbt_utils.group_by(2) }} 
),

net_income_loss as (

    select *
    from revenue_starter

    join expense_starter 
        using (period_first_day, source_relation)
),

retained_earnings_starter as (

    select
        cast('9999' as {{ dbt.type_string() }}) as account_id,
        source_relation,
        cast('9999-00' as {{ dbt.type_string() }}) as account_number,
        cast('Net Income Adjustment' as {{ dbt.type_string() }}) as account_name,
        false as is_sub_account,
        cast(null as {{ dbt.type_string() }}) as parent_account_number,
        cast(null as {{ dbt.type_string() }}) as parent_account_name,
        cast('Equity' as {{ dbt.type_string() }}) as account_type,
        cast('RetainedEarnings' as {{ dbt.type_string() }}) as account_sub_type,
        cast('Equity' as {{ dbt.type_string() }}) as account_class,
        cast(null as {{ dbt.type_string() }}) as class_id,
        cast('balance_sheet' as {{ dbt.type_string() }}) as financial_statement_helper,
        cast({{ dbt.date_trunc("year", "period_first_day") }} as date) as date_year,
        cast(period_first_day as date) as period_first_day,
        {{ dbt.last_day("period_first_day", "month") }} as period_last_day,
        (revenue_net_change - expense_net_change) as period_net_change,
        (revenue_net_converted_change - expense_net_converted_change) as period_net_converted_change
    from net_income_loss
),


retained_earnings_beginning as (

    select
        *,
        sum(coalesce(period_net_change, 0)) over (order by source_relation, period_first_day, period_first_day rows unbounded preceding) as period_ending_balance,
        sum(coalesce(period_net_converted_change, 0)) over (order by source_relation, period_first_day, period_first_day rows unbounded preceding) as period_ending_converted_balance
    from retained_earnings_starter
),

final as (
    
    select
        account_id,
        source_relation,
        account_number,
        account_name,
        is_sub_account,
        parent_account_number,
        parent_account_name,
        account_type,
        account_sub_type,
        account_class,
        class_id,
        financial_statement_helper,
        date_year,
        period_first_day,
        period_last_day,
        period_net_change,
        lag(coalesce(period_ending_balance,0)) over (order by source_relation, period_first_day) as period_beginning_balance,
        period_ending_balance,
        period_net_converted_change,
        lag(coalesce(period_ending_balance,0)) over (order by source_relation, period_first_day) as period_beginning_converted_balance,
        period_ending_converted_balance
    from retained_earnings_beginning
)

select *
from final
