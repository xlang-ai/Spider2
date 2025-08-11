with interview as (

    select *
    from {{ ref('greenhouse__interview_enhanced') }}
),

scorecard_attribute as (

    select *
    from {{ ref('stg_greenhouse__scorecard_attribute') }}
),

join_w_attributes as (

    select
        scorecard_attribute.*,
        interview.overall_recommendation,
    
        interview.candidate_name,
        interview.interviewer_name,
        interview.interview_name,
        
        interview.start_at as interview_start_at,
        interview.scorecard_submitted_at,

        interview.application_id,
        interview.job_title,
        interview.job_id,
        interview.hiring_managers,
        interview.interview_scorecard_key
        
    from interview left join scorecard_attribute using(scorecard_id)
),

final as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['interview_scorecard_key', 'index']) }} as scorecard_attribute_key

    from join_w_attributes
)

select *
from final