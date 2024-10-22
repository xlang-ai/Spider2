with 

source as (

    select * from {{ ref('status') }}

),

renamed as (

    select
        statusid,
        status

    from source

)

select * from renamed
