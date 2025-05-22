with calendar as (

    select *
    from {{ ref('xero__calendar_spine') }}

), ledger as (

    select *
    from {{ ref('xero__general_ledger') }}

), joined as (

    select 
        {{ dbt_utils.generate_surrogate_key(['calendar.date_month','ledger.account_id','ledger.source_relation']) }} as profit_and_loss_id,
        calendar.date_month, 
        ledger.account_id,
        ledger.account_name,
        ledger.account_code,
        ledger.account_type, 
        ledger.account_class, 
        ledger.source_relation, 
        coalesce(sum(ledger.net_amount * -1),0) as net_amount
    from calendar
    left join ledger
        on calendar.date_month = cast({{ dbt.date_trunc('month', 'ledger.journal_date') }} as date)
    where ledger.account_class in ('REVENUE','EXPENSE')
    {{ dbt_utils.group_by(8) }}

)

select *
from joined