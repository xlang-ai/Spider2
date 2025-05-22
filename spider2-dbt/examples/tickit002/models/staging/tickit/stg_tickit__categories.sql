with source as (

    select * from {{ source('tickit_external', 'category') }}

),

renamed as (

    select
        catid as cat_id,
        catgroup as cat_group,
        catname as cat_name,
        catdesc as cat_desc
    from
        source
    where
        cat_id IS NOT NULL
    order by
        cat_id

)

select * from renamed