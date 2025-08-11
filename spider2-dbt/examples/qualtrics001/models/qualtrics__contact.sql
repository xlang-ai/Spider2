with contacts as (

    select *
    from {{ ref('int_qualtrics__contacts') }}
),

directory as (

    select *
    from {{ var('directory') }}
),

distribution_contact as (

    select *
    from {{ var('distribution_contact') }}
),

distribution as (
-- just to grab survey id 
    select *
    from {{ var('distribution') }}
),

survey_response as (

    select *
    from {{ var('survey_response') }}
),

distribution_response as (

    select
        distribution_contact.*,
        distribution.survey_id,
        survey_response.distribution_channel,
        survey_response.progress,
        survey_response.duration_in_seconds,
        survey_response.is_finished,
        survey_response.recorded_date

    from distribution_contact 
    left join distribution
        on distribution_contact.distribution_id = distribution.distribution_id
        and distribution_contact.source_relation = distribution.source_relation
    left join survey_response
        on distribution_contact.response_id = survey_response.response_id
        and distribution.survey_id = survey_response.survey_id
        and distribution_contact.source_relation = survey_response.source_relation
),

agg_distribution_responses as (

    select 
        contact_id,
        source_relation,
        count(distinct case when sent_at is not null and distribution_channel = 'email' then survey_id end) as count_surveys_sent_email,
        count(distinct case when sent_at is not null and distribution_channel = 'smsinvite' then survey_id end) as count_surveys_sent_sms,
        count(distinct case when opened_at is not null and distribution_channel = 'email' then survey_id end) as count_surveys_opened_email,
        count(distinct case when opened_at is not null and distribution_channel = 'smsinvite' then survey_id end) as count_surveys_opened_sms,
        count(distinct case when response_started_at is not null and distribution_channel = 'email' then survey_id end) as count_surveys_started_email,
        count(distinct case when response_started_at is not null and distribution_channel = 'smsinvite' then survey_id end) as count_surveys_started_sms,
        count(distinct case when response_completed_at is not null and distribution_channel = 'email' then survey_id end) as count_surveys_completed_email,
        count(distinct case when response_completed_at is not null and distribution_channel = 'smsinvite' then survey_id end) as count_surveys_completed_sms
    from distribution_response
    group by 1,2
),

agg_survey_responses as (

    select 
        contact_id,
        source_relation,
        count(distinct survey_id) as total_count_surveys,
        count(distinct case when is_finished then survey_id else null end) as total_count_completed_surveys,
        avg(progress) as avg_survey_progress_pct,
        avg(duration_in_seconds) as avg_survey_duration_in_seconds,
        max(recorded_date) as last_survey_response_recorded_at,
        min(recorded_date) as first_survey_response_recorded_at
        
    from distribution_response
    group by 1,2
),

calc_medians as (

    select 
        contact_id,
        source_relation,
        median_survey_duration_in_seconds,
        median_survey_progress_pct
        
    from (
        select 
            contact_id, 
            source_relation,
            {{ fivetran_utils.percentile(percentile_field='duration_in_seconds', partition_field='contact_id,source_relation', percent='0.5') }} as median_survey_duration_in_seconds,
            {{ fivetran_utils.percentile(percentile_field='progress', partition_field='contact_id,source_relation', percent='0.5') }} as median_survey_progress_pct

        from distribution_response
        {% if target.type == 'postgres' %} group by 1,2 {% endif %} -- percentile macro uses an aggregate function on postgres and window functions on other DBs
    ) as rollup_medians
    {% if target.type != 'postgres' %} group by 1,2,3,4 {% endif %} -- roll up if using window function
),

final as (
    
    select 
        contacts.*,
        coalesce(agg_distribution_responses.count_surveys_sent_email, 0) as count_surveys_sent_email,
        coalesce(agg_distribution_responses.count_surveys_sent_sms, 0) as count_surveys_sent_sms,
        coalesce(agg_distribution_responses.count_surveys_opened_email, 0) as count_surveys_opened_email,
        coalesce(agg_distribution_responses.count_surveys_opened_sms, 0) as count_surveys_opened_sms,
        coalesce(agg_distribution_responses.count_surveys_started_email, 0) as count_surveys_started_email,
        coalesce(agg_distribution_responses.count_surveys_started_sms, 0) as count_surveys_started_sms,
        coalesce(agg_distribution_responses.count_surveys_completed_email, 0) as count_surveys_completed_email,
        coalesce(agg_distribution_responses.count_surveys_completed_sms, 0) as count_surveys_completed_sms,
        coalesce(agg_survey_responses.total_count_surveys, 0) as total_count_surveys,
        coalesce(agg_survey_responses.total_count_completed_surveys, 0) as total_count_completed_surveys,
        agg_survey_responses.avg_survey_progress_pct,
        agg_survey_responses.avg_survey_duration_in_seconds,
        calc_medians.median_survey_progress_pct,
        calc_medians.median_survey_duration_in_seconds,
        agg_survey_responses.last_survey_response_recorded_at,
        agg_survey_responses.first_survey_response_recorded_at,
        directory.name as directory_name,
        directory.is_default as is_in_default_directory,
        directory.is_deleted as is_directory_deleted

    from contacts
    left join agg_survey_responses
        on contacts.contact_id = agg_survey_responses.contact_id
        and contacts.source_relation = agg_survey_responses.source_relation
    left join agg_distribution_responses
        on contacts.contact_id = agg_distribution_responses.contact_id
        and contacts.source_relation = agg_distribution_responses.source_relation
    left join directory
        on contacts.directory_id = directory.directory_id 
        and contacts.source_relation = directory.source_relation
    left join calc_medians
        on contacts.contact_id = calc_medians.contact_id
        and contacts.source_relation = calc_medians.source_relation
)

select *
from final