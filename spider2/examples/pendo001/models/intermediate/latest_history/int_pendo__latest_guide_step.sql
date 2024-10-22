with guide_step_history as (

    select *
    from {{ var('guide_step_history') }}

),

latest_guide_step as (
    select
      *,
      row_number() over(partition by guide_id, step_id order by guide_last_updated_at desc) as latest_guide_step_index
    from guide_step_history
)

select *
from latest_guide_step
where latest_guide_step_index = 1