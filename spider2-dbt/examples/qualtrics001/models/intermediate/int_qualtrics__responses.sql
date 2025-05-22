with question_response as (

    select *
    from {{ var('question_response') }}
),

survey_response as (

    select *
    from {{ var('survey_response') }}
),

response_join as (

    select 
        question_response._fivetran_id as question_response_id,
        question_response.response_id as survey_response_id,
        survey_response.survey_id,
        question_response.question_id,
        question_response.question as question_text,
        question_response.sub_question_key,
        question_response.sub_question_text,
        question_response.question_option_key,
        question_response.value,
        question_response.loop_id,
        survey_response.distribution_channel,
        survey_response.status as survey_response_status,
        survey_response.progress as survey_progress,
        survey_response.duration_in_seconds,
        survey_response.is_finished as is_finished_with_survey,
        survey_response.finished_at as survey_finished_at,
        survey_response.last_modified_at as survey_response_last_modified_at,
        survey_response.recorded_date as survey_response_recorded_at,
        survey_response.started_at as survey_response_started_at,
        survey_response.recipient_email,
        survey_response.recipient_first_name,
        survey_response.recipient_last_name,
        survey_response.user_language,
        survey_response.ip_address,
        survey_response.location_latitude,
        survey_response.location_longitude,
        question_response.source_relation
    
    from question_response 
    inner join survey_response -- every question response will belong to an overall "survey response"
        on question_response.response_id = survey_response.response_id
        and question_response.source_relation = survey_response.source_relation
        
)

select *
from response_join