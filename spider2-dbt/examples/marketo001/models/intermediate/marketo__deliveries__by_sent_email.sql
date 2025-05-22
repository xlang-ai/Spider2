with activity as (

    select *
    from {{ var('activity_email_delivered') }}

), aggregate as (

    select 
        email_send_id,
        count(*) as count_deliveries
    from activity
    group by 1

)

select * 
from aggregate

