with page_history as (

    select *
    from {{ var('page_history') }}

),

latest_page as (
    select
      *,
      row_number() over(partition by page_id order by last_updated_at desc) as latest_page_index
    from page_history
)

select *
from latest_page
where latest_page_index = 1