{% macro engagements_aggregated(from_ref, primary_key) %}

    select
        {{ primary_key }},
        count(case when engagement_type = 'NOTE' then {{ primary_key }} end) as count_engagement_notes,
        count(case when engagement_type = 'TASK' then {{ primary_key }} end) as count_engagement_tasks,
        count(case when engagement_type = 'CALL' then {{ primary_key }} end) as count_engagement_calls,
        count(case when engagement_type = 'MEETING' then {{ primary_key }} end) as count_engagement_meetings,
        count(case when engagement_type = 'EMAIL' then {{ primary_key }} end) as count_engagement_emails,
        count(case when engagement_type = 'INCOMING_EMAIL' then {{ primary_key }} end) as count_engagement_incoming_emails,
        count(case when engagement_type = 'FORWARDED_EMAIL' then {{ primary_key }} end) as count_engagement_forwarded_emails
    from {{ from_ref }}
    group by 1

{% endmacro %}

{% macro engagement_metrics() %}

{% set metrics = [
    'count_engagement_notes',
    'count_engagement_tasks',
    'count_engagement_calls',
    'count_engagement_meetings',
    'count_engagement_emails',
    'count_engagement_incoming_emails',
    'count_engagement_forwarded_emails'
] %}

{{ return(metrics) }}

{% endmacro %}