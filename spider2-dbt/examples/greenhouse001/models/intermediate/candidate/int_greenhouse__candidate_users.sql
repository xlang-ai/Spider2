{{
  config(
    materialized = 'table'
    )
}}
with greenhouse_user as (

    select *
    from {{ ref('int_greenhouse__user_emails') }}
),

candidate as (

    select *
    from {{ ref('int_greenhouse__candidate_contacts') }}
),

-- necessary users = coordinator_user, recruiter_user
join_user_names as (

    select
        candidate.*,
        coordinator.full_name as coordinator_name,
        recruiter.full_name as recruiter_name,

        coordinator.email as coordinator_email,
        recruiter.email as recruiter_email

    from candidate

    left join greenhouse_user as coordinator
        on candidate.coordinator_user_id = coordinator.user_id
    left join greenhouse_user as recruiter
        on candidate.recruiter_user_id = recruiter.user_id 

)

select *
from join_user_names