with interview as (

    select *
    from {{ var('interview') }}

),

-- join with this to limit noise 
interview_feedback as (

    select *
    from {{ var('interview_feedback') }}
),

feedback_form as (

    select *
    from {{ var('feedback_form') }}

    where deleted_at is null
),

join_w_feedback as (

    select
        interview.*,
        feedback_form.feedback_form_id,
        feedback_form.creator_user_id as feedback_completer_user_id,
        feedback_form.completed_at as feedback_completed_at,

        feedback_form.instructions as feedback_form_instructions,
        feedback_form.score_system_value,
        feedback_form.form_title as feedback_form_title


    from interview
    left join interview_feedback 
        on interview.interview_id = interview_feedback.interview_id
    left join feedback_form 
        on interview_feedback.feedback_form_id = feedback_form.feedback_form_id
)

select *
from join_w_feedback