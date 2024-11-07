with 

source as (

    select * from {{ ref('qualifying') }}

),

renamed as (

    select
        qualifyid as qualify_id,
        raceid as race_id,
        driverid as driver_id,
        constructorid as constructor_id,
        number,
        position,
        q1,
        q2,
        q3

    from source

)

select * from renamed
