with base as (

    select *
    from {{ var('activity_send_email') }}

), windowed as (

    select 
        *,
        row_number() over (partition by email_send_id order by activity_timestamp asc) as activity_rank
    from base

), filtered as (

    select *
    from windowed
    where activity_rank = 1

)

select *
from filtered