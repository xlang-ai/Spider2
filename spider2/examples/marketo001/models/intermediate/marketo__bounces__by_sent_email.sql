with activity as (

    select *
    from {{ var('activity_email_bounced') }}

), aggregate as (

    select 
        email_send_id,
        count(*) as count_bounces
    from activity
    group by 1

)

select * 
from aggregate

