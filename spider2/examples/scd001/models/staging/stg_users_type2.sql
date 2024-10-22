with source as (

    select * from {{ source('main','raw_user') }}

),

renamed as (

    select
        id as user_id,
        name as user_name,
        email,
        
        {{ extract_email_domain('email') }} AS email_domain,
        
        gaggle_id, 
        created_at,
        effective_from_ts,
        effective_to_ts

    from source

)

select * from renamed