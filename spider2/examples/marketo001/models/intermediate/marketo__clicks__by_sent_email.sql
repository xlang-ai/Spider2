with activity as (

    select *
    from {{ var('activity_click_email') }}

), aggregate as (

    select 
        email_send_id,
        count(*) as count_clicks
    from activity
    group by 1

)

select * 
from aggregate

