with application_history as (

    select *
    from {{ var('application_history') }}

),

latest_application as (
    select
      *,
      row_number() over(partition by application_id order by last_updated_at desc) as latest_application_index
    from application_history
)

select *
from latest_application
where latest_application_index = 1