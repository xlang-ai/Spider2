with source as (

    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ source('main', 'raw_event') }}

),

renamed as (

    select
        event_id,
        user_id,
        event_name,
        timestamp

    from source

)

select * from renamed