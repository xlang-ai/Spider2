with sources as (

    select * from {{ source('tickit_external', 'sale') }}

),

renamed as (

    select
        salesid as sale_id,
        listid as list_id,
        sellerid as seller_id,
        buyerid as buyer_id,
        eventid as event_id,
        dateid as date_id,
        qtysold as qty_sold,
        round (pricepaid / qtysold, 2) as ticket_price,
        pricepaid as price_paid,
        round((commission / pricepaid) * 100, 2) as commission_prcnt,
        commission,
        (pricepaid - commission) as earnings,
        saletime as sale_time
    from
        sources
    where
        sale_id IS NOT NULL
    order by
        sale_id

)

select * from renamed