with visitor_history as (

    select *
    from {{ var('visitor_history') }}

),

latest_visitor as (
    select
      *,
      row_number() over(partition by visitor_id order by last_updated_at desc) as latest_visitor_index
    from visitor_history
)

select *
from latest_visitor
where latest_visitor_index = 1