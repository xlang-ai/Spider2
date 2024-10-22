with guide_history as (

    select *
    from {{ var('guide_history') }}

),

latest_guide as (
    select
      *,
      row_number() over(partition by guide_id order by last_updated_at desc) as latest_guide_index
    from guide_history
)

select *
from latest_guide
where latest_guide_index = 1