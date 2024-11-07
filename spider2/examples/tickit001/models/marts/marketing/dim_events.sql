{{ config(materialized='table', sort='event_id', dist='event_id') }}

with categories as (

    select * from {{ ref('stg_tickit__categories') }}

),

events as (

    select * from {{ ref('stg_tickit__events') }}

),

venues as (

    select * from {{ ref('stg_tickit__venues') }}

),

dates as (

    select * from {{ ref('stg_tickit__dates') }}

),

final as (

    select 
        e.event_id,
        e.event_name,
        e.start_time,
        v.venue_name,
        v.venue_city,
        v.venue_state,
        v.venue_seats,
        c.cat_group,
        c.cat_name,
        c.cat_desc,
        d.week,
        d.qtr,
        d.holiday
    from 
        events as e
            join categories as c on c.cat_id = e.cat_id
            join venues as v on v.venue_id = e.venue_id
            join dates as d on d.date_id = e.date_id

)

select * from final