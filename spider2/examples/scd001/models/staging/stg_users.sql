with source as (

    select * 
    from {{ source('main', 'raw_user') }}
    where effective_to_ts = '{{ var('high_timestamp') }}'

),

renamed as (

    select
        id as user_id,
        name as user_name,
        email,
        
        {{ extract_email_domain('email') }} AS email_domain,
        
        gaggle_id, 
        created_at

    from source

)

select * from renamed