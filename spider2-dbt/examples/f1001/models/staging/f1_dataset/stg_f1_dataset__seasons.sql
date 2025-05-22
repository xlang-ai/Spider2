with 

source as (

    select * from {{ ref('seasons') }}

),

renamed as (

    select
        year,
        url

    from source

)

select * from renamed
