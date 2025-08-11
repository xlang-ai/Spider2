with 

source as (

    select * from {{ ref('constructor_results') }}

),

renamed as (

    select
        constructorresultsid,
        raceid,
        constructorid,
        points,
        status

    from source

)

select * from renamed
