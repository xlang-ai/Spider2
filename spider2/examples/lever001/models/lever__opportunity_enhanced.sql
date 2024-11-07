with opportunity as (

    select *
    from {{ ref('int_lever__opportunity_contact_info') }}
),

stage as (

    select *
    from {{ var('stage') }}
),

archive_reason as (

    select *
    from {{ var('archive_reason') }}
),

opportunity_tags as (

    select *
    from {{ ref('int_lever__opportunity_tags') }}
),

-- gotta do this in case an opportunity has been sent multiple offer versions
order_offers as (

    select 
        *,
        row_number() over(partition by opportunity_id order by created_at desc) as row_num 
    from {{ var('offer') }}
),

last_offer as (

    select *
    from order_offers 
    where row_num = 1
),

-- to grab info about the job
posting as (

    select *
    from {{ ref('lever__posting_enhanced') }}
),

-- to produce some interview metrics 
interview_metrics as (

    select 
        opportunity_id,
        count(distinct interview_id) as count_interviews,
        count(distinct interviewer_user_id) as count_interviewers, 
        max(occurred_at) as latest_interview_scheduled_at,
        max(case when interviewer_is_hiring_manager then 1 else 0 end) as has_interviewed_w_hiring_manager

    from {{ ref('lever__interview_enhanced') }}

    group by 1
),

final as (

    select 
        opportunity.*,

        stage.stage_name as current_stage,
        opportunity_tags.tags, 
        archive_reason.archive_reason_title as archive_reason,

        posting.job_title,
        posting.job_commitment,
        posting.job_department,
        posting.job_level,
        posting.job_location,
        posting.job_team,
        posting.current_state as current_state_of_job_posting,
        -- time from first application for this posting
        {{ dbt.datediff('posting.first_app_sent_at', 'opportunity.created_at', 'day') }} as opp_created_n_days_after_first_app,

        last_offer.opportunity_id is not null as has_offer,
        last_offer.status as current_offer_status,

        coalesce(interview_metrics.count_interviews, 0) as count_interviews,
        coalesce(interview_metrics.count_interviewers, 0) as count_interviewers,
        interview_metrics.latest_interview_scheduled_at,
        case when coalesce(interview_metrics.has_interviewed_w_hiring_manager, 0) = 0 then false else true end as has_interviewed_w_hiring_manager

    from opportunity
    join stage  
        on opportunity.stage_id = stage.stage_id
    left join archive_reason
        on opportunity.archived_reason_id = archive_reason.archive_reason_id
    left join opportunity_tags
        on opportunity.opportunity_id = opportunity_tags.opportunity_id
    left join last_offer
        on opportunity.opportunity_id = last_offer.opportunity_id
    left join posting
        on opportunity.posting_id = posting.posting_id
    left join interview_metrics 
        on opportunity.opportunity_id = interview_metrics.opportunity_id 
)

select * from final