with sales as (

    select * from {{ ref('stg_tickit__sales') }}

),

users as (

    select * from {{ ref('stg_tickit__users') }}

),

first_purchase as (
    select min(CAST(sale_time AS DATE)) as first_purchase_date, buyer_id
    from sales
    group by buyer_id
),

final as (

    select distinct
        u.user_id,
        u.username,
        cast((u.last_name||', '||u.first_name) as varchar(100)) as full_name,
        f.first_purchase_date,
        u.city,
        u.state,
        u.email,
        u.phone,
        u.like_broadway,
        u.like_classical,
        u.like_concerts,
        u.like_jazz,
        u.like_musicals,
        u.like_opera,
        u.like_rock,
        u.like_sports,
        u.like_theatre,
        u.like_vegas
    from 
        sales as s
            join users as u on u.user_id = s.buyer_id
            join first_purchase as f on f.buyer_id = s.buyer_id
    order by 
        user_id

)

select * from final