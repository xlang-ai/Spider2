{{ config(materialized='table', sort='sale_id', dist='sale_id') }}

with categories as (

    select * from {{ ref('stg_tickit__categories') }}

),

dates as (

    select * from {{ ref('stg_tickit__dates') }}

),

events as (

    select * from {{ ref('stg_tickit__events') }}

),

listings as (

    select * from {{ ref('stg_tickit__listings') }}

),

sales as (

    select * from {{ ref('stg_tickit__sales') }}

),

sellers as (

    select * from {{ ref('int_sellers_extracted_from_users') }}

),

buyers as (

    select * from {{ ref('int_buyers_extracted_from_users') }}

),

event_categories as (

	select 
        e.event_id,
        e.event_name,
		c.cat_group,
		c.cat_name
	from events as e
		join categories as c on c.cat_id = e.cat_id

),

final as (

    select
        s.sale_id,
        s.sale_time,
        d.qtr,
        ec.cat_group,
        ec.cat_name,
        ec.event_name,
        b.username as buyer_username,
        b.full_name as buyer_name,
        b.state as buyer_state,
        b.first_purchase_date as buyer_first_purchase_date,
        se.username as seller_username,
        se.full_name as seller_name,
        se.state as seller_state,
        se.first_sale_date as seller_first_sale_date,
        s.ticket_price,
        s.qty_sold,
        s.price_paid,
        s.commission_prcnt,
        s.commission,
        s.earnings
    from 
        sales as s
            join listings as l on l.list_id = s.list_id
            join buyers as b on b.user_id = s.buyer_id
            join sellers as se on se.user_id = s.seller_id
            join event_categories as ec on ec.event_id = s.event_id
            join dates as d on d.date_id = s.date_id
    order by
        sale_id
)

select * from final