with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ source('main','raw_gaggle') }}

),

renamed as (

    select
        id as gaggle_id,
        name as gaggle_name,
        created_at

    from source

)

select * from renamed