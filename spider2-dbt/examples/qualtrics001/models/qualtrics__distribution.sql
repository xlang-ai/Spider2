with distribution as (

    select *
    from {{ var('distribution') }}
),

qualtrics_user as (

    select *
    from {{ var('user') }}
),

directory_mailing_list as (

    select *
    from {{ var('directory_mailing_list') }}
),

{% if var('qualtrics__using_core_mailing_lists', false) %}
core_mailing_list as (

    select *
    from {{ var('core_mailing_list') }}
),
{% endif %}

distribution_contact as (

    select 
        *,
        -- all relative to sent_at (should response be relative to opened_at?)
        {{ fivetran_utils.timestamp_diff(first_date="sent_at", second_date="opened_at", datepart="second") }} as time_to_open_in_seconds,
        {{ fivetran_utils.timestamp_diff(first_date="sent_at", second_date="response_started_at", datepart="second") }} as time_to_start_in_seconds,
        {{ fivetran_utils.timestamp_diff(first_date="sent_at", second_date="response_completed_at", datepart="second") }} as time_to_complete_in_seconds


    from {{ var('distribution_contact') }}
),

pivoted_metrics as (

    select 
        distribution_id,
        source_relation,
        -- current metrics
        {% for status in ('pending','success','error','opened','complaint','skipped','blocked','failure','unknown','softbounce','hardbounce','surveystarted','surveypartiallyfinished', 'surveyfinished','surveyscreenedout','sessionexpired') %}
        sum(case when lower(status) = '{{ status }}' then 1 else 0 end) as current_count_surveys_{{ status }},
        {% endfor %}
        count(distinct contact_id) as total_count_contacts,
        count(distinct case when sent_at is not null then contact_id else null end) as count_contacts_sent_surveys,
        count(distinct case when opened_at is not null then contact_id else null end) as count_contacts_opened_surveys,
        count(distinct case when response_started_at is not null then contact_id else null end) as count_contacts_started_surveys,
        count(distinct case when response_completed_at is not null then contact_id else null end) as count_contacts_completed_surveys,
        min(sent_at) as first_survey_sent_at,
        max(sent_at) as last_survey_sent_at,
        min(opened_at) as first_survey_opened_at,
        max(opened_at) as last_survey_opened_at,
        min(response_completed_at) as first_response_completed_at,
        max(response_completed_at) as last_response_completed_at,
        avg(time_to_open_in_seconds) as avg_time_to_open_in_seconds,
        avg(time_to_start_in_seconds) as avg_time_to_start_in_seconds,
        avg(time_to_complete_in_seconds) as avg_time_to_complete_in_seconds

    from distribution_contact
    group by 1,2
),

calc_medians as (
    
    select 
        distribution_id,
        source_relation,
        median_time_to_open_in_seconds,
        median_time_to_start_in_seconds,
        median_time_to_complete_in_seconds
    from (
        select 
            distribution_id, 
            source_relation,
            {{ fivetran_utils.percentile(percentile_field='time_to_open_in_seconds', partition_field='distribution_id,source_relation', percent='0.5') }} as median_time_to_open_in_seconds,
            {{ fivetran_utils.percentile(percentile_field='time_to_start_in_seconds', partition_field='distribution_id,source_relation', percent='0.5') }} as median_time_to_start_in_seconds,
            {{ fivetran_utils.percentile(percentile_field='time_to_complete_in_seconds', partition_field='distribution_id,source_relation', percent='0.5') }} as median_time_to_complete_in_seconds

        from distribution_contact
        {% if target.type == 'postgres' %} group by 1,2 {% endif %} -- percentile macro uses an aggregate function on postgres and window functions on other DBs
    ) as rollup_medians
    {% if target.type != 'postgres' %} group by 1,2,3,4,5 {% endif %} -- roll up if using window function
),

final as (

    select 
        distribution.*,
        parent_distribution.header_subject as parent_distribution_header_subject,
        {% if var('qualtrics__using_core_mailing_lists', false) -%} coalesce(directory_mailing_list.name, core_mailing_list.name) {%- else %} directory_mailing_list.name {%- endif %} as recipient_mailing_list_name,
        qualtrics_user.email as owner_email,
        qualtrics_user.first_name as owner_first_name,
        qualtrics_user.last_name as owner_last_name,
        {% for status in ('pending','success','error','opened','complaint','skipped','blocked','failure','unknown','softbounce','hardbounce','surveystarted','surveypartiallyfinished','surveyfinished','surveyscreenedout','sessionexpired') %}
        coalesce(pivoted_metrics.current_count_surveys_{{ status }}, 0) as current_count_surveys_{{ status }},
        {% endfor %}
        coalesce(pivoted_metrics.total_count_contacts, 0) as total_count_contacts,
        coalesce(pivoted_metrics.count_contacts_sent_surveys, 0) as count_contacts_sent_surveys,
        coalesce(pivoted_metrics.count_contacts_opened_surveys, 0) as count_contacts_opened_surveys,
        coalesce(pivoted_metrics.count_contacts_started_surveys, 0) as count_contacts_started_surveys,
        coalesce(pivoted_metrics.count_contacts_completed_surveys, 0) as count_contacts_completed_surveys,
        pivoted_metrics.first_survey_sent_at,
        pivoted_metrics.last_survey_sent_at,
        pivoted_metrics.first_survey_opened_at,
        pivoted_metrics.last_survey_opened_at,
        pivoted_metrics.first_response_completed_at,
        pivoted_metrics.last_response_completed_at,
        pivoted_metrics.avg_time_to_open_in_seconds,
        pivoted_metrics.avg_time_to_start_in_seconds,
        pivoted_metrics.avg_time_to_complete_in_seconds,
        calc_medians.median_time_to_open_in_seconds,
        calc_medians.median_time_to_start_in_seconds,
        calc_medians.median_time_to_complete_in_seconds

    from distribution
    left join qualtrics_user 
        on distribution.owner_user_id = qualtrics_user.user_id 
        and distribution.source_relation = qualtrics_user.source_relation
    left join distribution as parent_distribution
        on distribution.parent_distribution_id = parent_distribution.distribution_id
        and distribution.source_relation = parent_distribution.source_relation
    left join pivoted_metrics 
        on distribution.distribution_id = pivoted_metrics.distribution_id 
        and distribution.source_relation = pivoted_metrics.source_relation
    left join calc_medians 
        on distribution.distribution_id = calc_medians.distribution_id 
        and distribution.source_relation = calc_medians.source_relation
    left join directory_mailing_list
        on distribution.recipient_mailing_list_id = directory_mailing_list.mailing_list_id
        and distribution.source_relation = directory_mailing_list.source_relation
    {% if var('qualtrics__using_core_mailing_lists', false) %}
    left join core_mailing_list
        on distribution.recipient_mailing_list_id = core_mailing_list.mailing_list_id
        and distribution.source_relation = core_mailing_list.source_relation
    {% endif %}
)

select *
from final