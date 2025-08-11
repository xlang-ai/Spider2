with candidate as (

    select *
    from {{ ref('stg_greenhouse__candidate') }}
),

-- candidates can have multiple phones + emails
phones as (

    select 
        candidate_id,
        {{ fivetran_utils.string_agg("phone_type || ': ' || phone_number" , "', '") }} as phone

    from {{ ref('stg_greenhouse__phone_number') }}

    group by 1
),

emails as (

    select 
        candidate_id,
        {{ fivetran_utils.string_agg("'<' || email || '>'" , "', '") }} as email
    from {{ ref('stg_greenhouse__email_address') }}

    group by 1
),

-- getting the last resume uploaded
order_resumes as (

    select 
        *,
        row_number() over(partition by candidate_id order by index desc) as resume_row_num
    from {{ ref('stg_greenhouse__attachment') }}

    where lower(type) = 'resume'
),

latest_resume as (

    select *
    from order_resumes 
    where resume_row_num = 1
),

order_links as (

    select 
        candidate_id,
        lower(url) as url,
        row_number() over(partition by candidate_id, lower(url) like '%linkedin%' order by index desc) as linkedin_row_num,
        row_number() over(partition by candidate_id, lower(url) like '%github%' order by index desc) as github_row_num

    from {{ ref('stg_greenhouse__social_media_address') }}

    where lower(url) like '%linkedin%' or lower(url) like '%github%'

),

latest_links as (

    select
        candidate_id,
        max(case when linkedin_row_num = 1 and url like '%linkedin%' then url end) as linkedin_url,
        max(case when github_row_num = 1 and url like '%github%' then url end) as github_url

    from order_links
    
    where (linkedin_row_num = 1 and url like '%linkedin%') or 
        (github_row_num = 1 and url like '%github%')
    
    group by 1
),

join_candidate_info as (

    select 
        candidate.*,
        phones.phone as phone,
        emails.email as email,
        latest_resume.url as resume_url,
        latest_links.linkedin_url,
        latest_links.github_url
    
    from 
    candidate
    left join phones
        on candidate.candidate_id = phones.candidate_id
    left join emails 
        on candidate.candidate_id = emails.candidate_id
    left join latest_resume
        on candidate.candidate_id = latest_resume.candidate_id
    left join latest_links
        on candidate.candidate_id = latest_links.candidate_id
)

select *
from join_candidate_info