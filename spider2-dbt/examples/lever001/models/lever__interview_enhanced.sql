-- note: each record is a unique interview-interviewer feedback form combo
-- an interview can have multiple interviewers, and interviewers can have multiple feedback forms
with interview as (

    select 
        *,
        cast( {{ dbt.dateadd(datepart='minute', interval='duration_minutes', from_date_or_timestamp='occurred_at') }}
            as {{ dbt.type_timestamp() }} ) as ended_at
    from {{ ref('int_lever__interview_users') }}
),

--  just to grab stufff
opportunity as (

    select *
    from {{ ref('int_lever__opportunity_users') }}
),

join_w_opportunity as (

    select
        interview.*,
        opportunity.opportunity_owner_name,
        opportunity.referrer_name,
        opportunity.hiring_manager_name,
        coalesce(lower(interview.inteviewer_name) = lower(opportunity.hiring_manager_name), false) as interviewer_is_hiring_manager,
        opportunity.contact_name as interviewee_name,
        opportunity.contact_location as interviewee_location,
        opportunity.origin as interviewee_origin,
        opportunity.contact_id as interviewee_contact_id,
        {{ dbt.datediff('opportunity.created_at', 'interview.occurred_at', 'day') }} as days_between_opp_created_and_interview,
        opportunity.last_advanced_at > interview.ended_at as has_advanced_since_interview

    from interview
    join opportunity using(opportunity_id)
)

select * from join_w_opportunity