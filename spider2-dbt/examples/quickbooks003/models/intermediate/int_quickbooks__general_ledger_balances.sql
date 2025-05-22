with general_ledger as (

    select *
    from {{ ref('quickbooks__general_ledger') }}
),

gl_accounting_periods as (

    select *
    from {{ ref('int_quickbooks__general_ledger_date_spine') }}
),

gl_period_balance as (

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
        financial_statement_helper,
        account_class,
        class_id,
        cast({{ dbt.date_trunc("year", "transaction_date") }} as date) as date_year,
        cast({{ dbt.date_trunc("month", "transaction_date") }} as date) as date_month,
        sum(adjusted_amount) as period_balance,
        sum(adjusted_converted_amount) as period_converted_balance
    from general_ledger

    {{ dbt_utils.group_by(14) }}
),

gl_cumulative_balance as (

    select
        *,
        case when financial_statement_helper = 'balance_sheet'
            then sum(period_balance) over (partition by account_id, class_id, source_relation 
            order by source_relation, date_month, account_id, class_id rows unbounded preceding) 
            else 0
                end as cumulative_balance,
        case when financial_statement_helper = 'balance_sheet'
            then sum(period_converted_balance) over (partition by account_id, class_id, source_relation 
            order by source_relation, date_month, account_id, class_id rows unbounded preceding) 
            else 0
                end as cumulative_converted_balance
    from gl_period_balance
),

gl_beginning_balance as (

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
        financial_statement_helper,
        account_class,
        class_id,
        date_year,
        date_month, 
        period_balance as period_net_change,
        case when financial_statement_helper = 'balance_sheet'
            then (cumulative_balance - period_balance) 
            else 0
                end as period_beginning_balance,
        cumulative_balance as period_ending_balance,
        period_converted_balance as period_net_converted_change,
        case when financial_statement_helper = 'balance_sheet'
            then (cumulative_converted_balance - period_converted_balance) 
            else 0
                end as period_beginning_converted_balance,
        cumulative_converted_balance as period_ending_converted_balance
    from gl_cumulative_balance
),

gl_patch as (

    select 
        coalesce(gl_beginning_balance.account_id, gl_accounting_periods.account_id) as account_id,
        coalesce(gl_beginning_balance.source_relation, gl_accounting_periods.source_relation) as source_relation,
        coalesce(gl_beginning_balance.account_number, gl_accounting_periods.account_number) as account_number,
        coalesce(gl_beginning_balance.account_name, gl_accounting_periods.account_name) as account_name,
        coalesce(gl_beginning_balance.is_sub_account, gl_accounting_periods.is_sub_account) as is_sub_account,
        coalesce(gl_beginning_balance.parent_account_number, gl_accounting_periods.parent_account_number) as parent_account_number,
        coalesce(gl_beginning_balance.parent_account_name, gl_accounting_periods.parent_account_name) as parent_account_name,
        coalesce(gl_beginning_balance.account_type, gl_accounting_periods.account_type) as account_type,
        coalesce(gl_beginning_balance.account_sub_type, gl_accounting_periods.account_sub_type) as account_sub_type,
        coalesce(gl_beginning_balance.account_class, gl_accounting_periods.account_class) as account_class,
        coalesce(gl_beginning_balance.class_id, gl_accounting_periods.class_id) as class_id,
        coalesce(gl_beginning_balance.financial_statement_helper, gl_accounting_periods.financial_statement_helper) as financial_statement_helper,
        coalesce(gl_beginning_balance.date_year, gl_accounting_periods.date_year) as date_year,
        gl_accounting_periods.period_first_day,
        gl_accounting_periods.period_last_day,
        gl_accounting_periods.period_index,
        gl_beginning_balance.period_net_change,
        gl_beginning_balance.period_beginning_balance,
        gl_beginning_balance.period_ending_balance,
        case when gl_beginning_balance.period_beginning_balance is null and period_index = 1
            then 0
            else gl_beginning_balance.period_beginning_balance
                end as period_beginning_balance_starter,
        case when gl_beginning_balance.period_ending_balance is null and period_index = 1
            then 0
            else gl_beginning_balance.period_ending_balance
                end as period_ending_balance_starter,
        gl_beginning_balance.period_net_converted_change,
        gl_beginning_balance.period_beginning_converted_balance,
        gl_beginning_balance.period_ending_converted_balance,
        case when gl_beginning_balance.period_beginning_converted_balance is null and period_index = 1
            then 0
            else gl_beginning_balance.period_beginning_converted_balance
                end as period_beginning_converted_balance_starter,
        case when gl_beginning_balance.period_ending_converted_balance is null and period_index = 1
            then 0
            else gl_beginning_balance.period_ending_converted_balance
                end as period_ending_converted_balance_starter
    from gl_accounting_periods

    left join gl_beginning_balance
        on gl_beginning_balance.account_id = gl_accounting_periods.account_id
            and gl_beginning_balance.source_relation = gl_accounting_periods.source_relation
            and gl_beginning_balance.date_month = gl_accounting_periods.period_first_day
            and gl_beginning_balance.date_year = gl_accounting_periods.date_year
            and coalesce(gl_beginning_balance.class_id, '0') = coalesce(gl_accounting_periods.class_id, '0')
),

gl_value_partition as (

    select
        *,
        sum(case when period_ending_balance_starter is null 
            then 0 
            else 1 
                end) over (order by source_relation, account_id, class_id, period_last_day rows unbounded preceding) as gl_partition,
        sum(case when period_ending_converted_balance_starter is null 
            then 0 
            else 1 
                end) over (order by source_relation, account_id, class_id, period_last_day rows unbounded preceding) as gl_converted_partition
    from gl_patch
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
        coalesce(period_net_change, 0) as period_net_change,
        coalesce(period_beginning_balance_starter,
            first_value(period_ending_balance_starter) over (partition by gl_partition, source_relation 
            order by source_relation, period_last_day rows unbounded preceding)) as period_beginning_balance,
        coalesce(period_ending_balance_starter,
            first_value(period_ending_balance_starter) over (partition by gl_partition, source_relation 
            order by source_relation, period_last_day rows unbounded preceding)) as period_ending_balance,
        coalesce(period_net_converted_change, 0) as period_net_converted_change,
        coalesce(period_beginning_converted_balance_starter,
            first_value(period_ending_converted_balance_starter) over (partition by gl_converted_partition, source_relation 
            order by source_relation, period_last_day rows unbounded preceding)) as period_beginning_converted_balance,
        coalesce(period_ending_converted_balance_starter,
            first_value(period_ending_converted_balance_starter) over (partition by gl_partition, source_relation 
            order by source_relation, period_last_day rows unbounded preceding)) as period_ending_converted_balance

    from gl_value_partition
)

select *
from final