with response as (

    select *
    from {{ ref('qualtrics__response') }}
),

contact as (

    select *
    from {{ ref('qualtrics__contact') }}
),

contact_mailing_list_membership as (

    select *
    from {{ var('contact_mailing_list_membership') }}
),

distribution_contact as (

    select *
    from {{ var('distribution_contact') }}
),

spine as (

    {% if execute %}
    {% set first_date_query %}
        select  coalesce( min( sent_at ), '2016-01-01') as min_date from {{ var('distribution_contact') }}
    {% endset %}
    {% set first_date = run_query(first_date_query).columns[0][0]|string %}
    
    {% else %} {% set first_date = "2016-01-01" %}
    {% endif %}

    {{ dbt_utils.date_spine(
        datepart = "day", 
        start_date =  "cast('" ~ first_date[0:10] ~ "' as date)", 
        end_date = dbt.dateadd("week", 1, dbt.date_trunc('day', dbt.current_timestamp_backcompat())) 
        ) 
    }} 
),

source_relations as (

    select
        distinct source_relation 
    from distribution_contact
),

spine_cross_join as (

    select 
        spine.date_day, 
        source_relations.source_relation
    from spine 
    cross join source_relations
),

agg_responses as (
    {# From https://qualtrics.com/support/survey-platform/distributions-module/distribution-summary/#ChannelCategorization #}
    {% set distribution_channels = ('anonymous', 'social', 'gl', 'qr', 'email', 'smsinvite') %}

    select 
        cast({{ dbt.date_trunc('day', 'survey_response_recorded_at') }} as date) as date_day,
        source_relation,
        count(distinct survey_id) as count_distinct_surveys_responded_to,
        count(distinct survey_response_id) as total_count_survey_responses,
        count(distinct case when is_finished_with_survey then survey_response_id end) as total_count_completed_survey_responses,

        {% for distribution_channel in distribution_channels %}
        count(distinct 
                case 
                when distribution_channel = '{{ distribution_channel }}' then survey_response_id
                else null end) as count_{{ distribution_channel }}_survey_responses,
        count(distinct 
                case 
                when distribution_channel = '{{ distribution_channel }}' and is_finished_with_survey then survey_response_id
                else null end) as count_{{ distribution_channel }}_completed_survey_responses,
        {% endfor %}
        count(distinct case 
                when distribution_channel not in {{ distribution_channels }} then survey_response_id
                else null end) as count_uncategorized_survey_responses,
        count(distinct case 
                when is_finished_with_survey and distribution_channel not in {{ distribution_channels }} then survey_response_id
                else null end) as count_uncategorized_completed_survey_responses
    from response 
    group by 1,2
),

agg_survey_distribution as (
-- all metrics here relative to the day that the survey was sent
    select 
        cast({{ dbt.date_trunc('day', 'sent_at') }} as date) as date_day,
        source_relation,
        count(distinct contact_id) as count_contacts_sent_surveys,
        count(distinct case when opened_at is not null then contact_id end) as count_contacts_opened_sent_surveys,
        count(distinct case when response_started_at is not null then contact_id end) as count_contacts_started_sent_surveys,
        count(distinct case when response_completed_at is not null then contact_id end) as count_contacts_completed_sent_surveys
    from distribution_contact
    group by 1,2
),

agg_created_contacts as (

    select
        cast({{ dbt.date_trunc('day', 'created_at') }} as date) as date_day,
        source_relation,
        count(distinct contact_id) as count_contacts_created
    from contact  
    group by 1,2
),

agg_directory_unsubscriptions as (

    select
        cast({{ dbt.date_trunc('day', 'unsubscribed_from_directory_at') }} as date) as date_day,
        source_relation,
        count(distinct contact_id) as count_contacts_unsubscribed_from_directory
    from contact
    group by 1,2
),

agg_mailing_list_unsubscriptions as (

    select
        cast({{ dbt.date_trunc('day', 'unsubscribed_at') }} as date) as date_day,
        source_relation,
        count(distinct contact_id) as count_contacts_unsubscribed_from_mailing_list
    from contact_mailing_list_membership
    group by 1,2
),

final as (

    select 
        coalesce(agg_responses.source_relation, agg_survey_distribution.source_relation, agg_created_contacts.source_relation, agg_directory_unsubscriptions.source_relation, agg_mailing_list_unsubscriptions.source_relation, spine_cross_join.source_relation) as source_relation,
        spine_cross_join.date_day,
        coalesce(agg_created_contacts.count_contacts_created, 0) as count_contacts_created,
        coalesce(agg_directory_unsubscriptions.count_contacts_unsubscribed_from_directory, 0) as count_contacts_unsubscribed_from_directory,
        coalesce(agg_mailing_list_unsubscriptions.count_contacts_unsubscribed_from_mailing_list, 0) as count_contacts_unsubscribed_from_mailing_list,

        coalesce(agg_survey_distribution.count_contacts_sent_surveys, 0) as count_contacts_sent_surveys,
        coalesce(agg_survey_distribution.count_contacts_opened_sent_surveys, 0) as count_contacts_opened_sent_surveys,
        coalesce(agg_survey_distribution.count_contacts_started_sent_surveys, 0) as count_contacts_started_sent_surveys,
        coalesce(agg_survey_distribution.count_contacts_completed_sent_surveys, 0) as count_contacts_completed_sent_surveys,

        coalesce(agg_responses.count_distinct_surveys_responded_to, 0) as count_distinct_surveys_responded_to,
        coalesce(agg_responses.total_count_survey_responses, 0) as total_count_survey_responses,
        coalesce(agg_responses.total_count_completed_survey_responses, 0) as total_count_completed_survey_responses,

        -- distribution channels
        coalesce(agg_responses.count_anonymous_survey_responses, 0) as count_anonymous_survey_responses,
        coalesce(agg_responses.count_anonymous_completed_survey_responses, 0) as count_anonymous_completed_survey_responses,
        coalesce(agg_responses.count_social_survey_responses, 0) as count_social_media_survey_responses,
        coalesce(agg_responses.count_social_completed_survey_responses, 0) as count_social_media_completed_survey_responses,
        coalesce(agg_responses.count_gl_survey_responses, 0) as count_personal_link_survey_responses,
        coalesce(agg_responses.count_gl_completed_survey_responses, 0) as count_personal_link_completed_survey_responses,
        coalesce(agg_responses.count_qr_survey_responses, 0) as count_qr_code_survey_responses,
        coalesce(agg_responses.count_qr_completed_survey_responses, 0) as count_qr_code_completed_survey_responses,
        coalesce(agg_responses.count_email_survey_responses, 0) as count_email_survey_responses,
        coalesce(agg_responses.count_email_completed_survey_responses, 0) as count_email_completed_survey_responses,
        coalesce(agg_responses.count_smsinvite_survey_responses, 0) as count_sms_survey_responses,
        coalesce(agg_responses.count_smsinvite_completed_survey_responses, 0) as count_sms_completed_survey_responses,
        coalesce(agg_responses.count_uncategorized_survey_responses, 0) as count_uncategorized_survey_responses,
        coalesce(agg_responses.count_uncategorized_completed_survey_responses, 0) as count_uncategorized_completed_survey_responses

    from spine_cross_join
    left join agg_responses
        on spine_cross_join.date_day = agg_responses.date_day
            and spine_cross_join.source_relation = agg_responses.source_relation
    left join agg_survey_distribution
        on spine_cross_join.date_day = agg_survey_distribution.date_day
            and spine_cross_join.source_relation = agg_survey_distribution.source_relation
    left join agg_created_contacts
        on spine_cross_join.date_day = agg_created_contacts.date_day
            and spine_cross_join.source_relation = agg_created_contacts.source_relation
    left join agg_directory_unsubscriptions
        on spine_cross_join.date_day = agg_directory_unsubscriptions.date_day
            and spine_cross_join.source_relation = agg_directory_unsubscriptions.source_relation
    left join agg_mailing_list_unsubscriptions
        on spine_cross_join.date_day = agg_mailing_list_unsubscriptions.date_day
            and spine_cross_join.source_relation = agg_mailing_list_unsubscriptions.source_relation
    
)

select * 
from final