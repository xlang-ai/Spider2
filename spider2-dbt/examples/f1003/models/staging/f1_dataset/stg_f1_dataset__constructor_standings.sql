with 

source as (

    select * from {{ ref('constructor_standings') }}

),

renamed as (

    select
        constructorstandingsid,
        raceid,
        constructorid,
        points,
        position,
        positiontext,
        wins

    from source

)

select * from renamed
