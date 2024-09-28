select * from
(
    select
        'Seller with most unique customers :-' as Description,
        raw.seller_id as Seller_ID,
        count(distinct customer_unique_id) as Value
    from (
        select
            c.customer_id,
            c.customer_unique_id,
            s.seller_id,
            o.order_id,
            o.order_status,
            i.order_item_id,
            i.product_id,
            i.price,
            i.freight_value,
            s.seller_city,
            s.seller_state,
            c.customer_city,
            c.customer_state,
            o.order_delivered_customer_date
        from olist_orders o
        join olist_customers c
            on o.customer_id=c.customer_id
        join olist_order_items i
            on o.order_id=i.order_id
        join olist_sellers s
            on i.seller_id=s.seller_id
        where order_status='delivered'
        group by 1,2,3,5,6,7,8,9,10,11,12,13
    ) raw
)
union all
select * from (
    select
        'Seller with highest Profit :-' as Description,
        raw.seller_id as Seller_ID,
        sum(raw.profit) as Value
    from (
        select
            c.customer_id,
            c.customer_unique_id,
            s.seller_id,
            o.order_id,
            o.order_status,
            i.order_item_id,
            i.product_id,
            i.price,
            i.freight_value,
            i.price - i.freight_value as profit,
            s.seller_city,
            s.seller_state,
            c.customer_city,
            c.customer_state,
            o.order_delivered_customer_date
        from olist_orders o
        join olist_customers c
            on o.customer_id=c.customer_id
        join olist_order_items i
            on o.order_id=i.order_id
        join olist_sellers s
            on i.seller_id=s.seller_id
        where order_status='delivered'
        group by 1,2,3,5,6,7,8,9,10,11,12,13
    ) raw
)
union all
select * from (
    select
        'Seller with most unique orders :-' as Description,
        raw.seller_id as Seller_ID,
        count(distinct order_id) as Value
    from (
        select
            c.customer_id,
            c.customer_unique_id,
            s.seller_id,
            o.order_id,
            o.order_status,
            i.order_item_id,
            i.product_id,
            i.price,
            i.freight_value,
            s.seller_city,
            s.seller_state,
            c.customer_city,
            c.customer_state,
            o.order_delivered_customer_date
        from olist_orders o
        join olist_customers c
            on o.customer_id=c.customer_id
        join olist_order_items i
            on o.order_id=i.order_id
        join olist_sellers s
            on i.seller_id=s.seller_id
        where order_status='delivered'
        group by 1,2,3,5,6,7,8,9,10,11,12,13
    ) raw
)
union all
select * from (
    select
        'Seller with most 5 star ratings :-' as Description,
        raw.seller_id as Seller_ID,
        count(raw.review_score) as Value
    from (
        select
            c.customer_id,
            c.customer_unique_id,
            s.seller_id,
            o.order_id,
            o.order_status,
            r.review_score,
            i.order_item_id,
            i.product_id,
            i.price,
            i.freight_value,
            s.seller_city,
            s.seller_state,
            c.customer_city,
            c.customer_state,
            o.order_delivered_customer_date
        from olist_orders o
        join olist_customers c
            on o.customer_id=c.customer_id
        join olist_order_items i
            on o.order_id=i.order_id
        join olist_sellers s
            on i.seller_id=s.seller_id
        join olist_order_reviews r
            on o.order_id=r.order_id
        where order_status='delivered'
        group by 1,2,3,5,6,7,8,9,10,11,12,13
        having r.review_score > 4
    ) raw
)