with activity as (

    select *
    from {{ var('activity_unsubscribe_email') }}

), aggregate as (

    select 
        email_send_id,
        count(*) as count_unsubscribes
    from activity
    group by 1

)

select * 
from aggregate

