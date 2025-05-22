with interview as (

    select *
    from {{ ref('int_greenhouse__interview_scorecard') }}
),

greenhouse_user as (

    select *
    from {{ ref('int_greenhouse__user_emails') }}
),

-- necessary users = interviewer_user_id, scorecard_submitted_by_user_id, organizer_user_id
join_user_names as (

    select
        interview.*,
        interviewer.full_name as interviewer_name,
        scorecard_submitter.full_name as scorecard_submitter_name,
        organizer.full_name as organizer_name,
        interviewer.email as interviewer_email

    from interview

    left join greenhouse_user as interviewer
        on interview.interviewer_user_id = interviewer.user_id
    left join greenhouse_user as scorecard_submitter
        on interview.scorecard_submitted_by_user_id = scorecard_submitter.user_id 
    left join greenhouse_user as organizer
        on interview.organizer_user_id = organizer.user_id 

)

select * from join_user_names