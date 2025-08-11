with account_history as (

    select *
    from {{ var('account_history') }}

),

latest_account as (
    select
      *,
      row_number() over(partition by account_id order by last_updated_at desc) as latest_account_index
    from account_history
)

select *
from latest_account
where latest_account_index = 1