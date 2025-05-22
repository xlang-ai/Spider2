with page_rule_history as (

    select *
    from {{ var('page_rule_history') }}

),

latest_page_rule as (
    select
      *,
      row_number() over(partition by page_id, rule order by page_last_updated_at desc) as latest_page_rule_index
    from page_rule_history
)

select *
from latest_page_rule
where latest_page_rule_index = 1