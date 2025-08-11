with posting_interview as (

    select *
    from {{ var('posting_interview') }}

),

interview as (

    select 
        interview_id,
        opportunity_id 

    from {{ var('interview') }}

),

posting_interview_metrics as (
    
    select
        posting_interview.posting_id,
        count(distinct posting_interview.interview_id) as count_interviews,
        count(distinct interview.opportunity_id) as count_interviewees

    from posting_interview 
    join interview using(interview_id)
    group by 1

)

select * from posting_interview_metrics