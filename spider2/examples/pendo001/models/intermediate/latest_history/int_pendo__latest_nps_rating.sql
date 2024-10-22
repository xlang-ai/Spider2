with poll as (

    select *
    from {{ var('poll') }}

    where lower(attribute_type) = 'npsrating'

),

poll_event as (

    select *
    from {{ var('poll_event') }}
),

limit_to_nps_polls as (

    select 
        poll_event.*
    
    from poll_event
    join poll 
        on poll_event.poll_id = poll.poll_id
),

order_responses as (

    select
        *,
        row_number() over(partition by visitor_id order by occurred_at desc) as latest_response_index
    from limit_to_nps_polls
),

latest_response as (

    select 
        visitor_id,
        account_id,
        cast(poll_response as {{ dbt.type_int() }}) as nps_rating

    from order_responses
    where latest_response_index = 1

)

select *
from latest_response