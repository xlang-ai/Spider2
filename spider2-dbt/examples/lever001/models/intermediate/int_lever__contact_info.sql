with contact_phones as (

    select 
        contact_id,
        {{ fivetran_utils.string_agg("phone_type || ': ' || phone_number" , "', '") }} as phones

    from {{ var('contact_phone') }}

    group by 1
),

contact_emails as (

    select 
        contact_id,
        {{ fivetran_utils.string_agg("'<' || email || '>'" , "', '") }} as emails

    from {{ var('contact_email') }}

    group by 1
),

contact_links as (

    select 
        contact_id,

        -- ideally, people only have one of each type of these links. 
        -- taking the max as that will produce a more constant result than ordering via row_number() window
        -- function ordering by _fivetran_synced

        max(case when lower(link) like '%linkedin.com%' then link end) as linkedin_link,
        max(case when lower(link) like '%github.com%' then link end) as github_link
    
    from {{ var('contact_link') }}
    group by 1
),

final as (

    select 
        contact_emails.*,
        contact_phones.phones,
        contact_links.linkedin_link,
        contact_links.github_link

    from contact_emails 
    left join contact_phones 
        on contact_emails.contact_id = contact_phones.contact_id
    left join contact_links 
        on contact_emails.contact_id = contact_links.contact_id
)

select * from final