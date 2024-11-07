with posting as (

    select *
    from {{ var('posting') }}
),

{% if var('lever_using_posting_tag', True) %}
posting_tags as (

    select *
    from {{ ref('int_lever__posting_tags') }}
),
{% endif %}

posting_applications as (

    select *
    from {{ ref('int_lever__posting_applications') }}
),

posting_interviews as (

    select *
    from {{ ref('int_lever__posting_interviews') }}
),

{% if var('lever_using_requisitions', True) %}
posting_requisitions as (

    select 
        posting_id,
        count(requisition_id) as count_requisitions
    from {{ var('requisition_posting') }}

    group by 1
),
{% endif %}

lever_user as (

    select *
    from {{ var('user') }}
),

final as (

    select 
        posting.*,
        posting_applications.first_app_sent_at,

        coalesce(posting_applications.count_referred_applications, 0) as count_referred_applications,
        coalesce(posting_applications.count_posting_applications, 0) as count_posting_applications,
        coalesce(posting_applications.count_manual_user_applications, 0) as count_manual_user_applications,
        coalesce(posting_applications.count_opportunities, 0) as count_opportunities,
        coalesce(posting_applications.count_open_opportunities, 0) as count_open_opportunities,

        coalesce(posting_interviews.count_interviews, 0) as count_interviews,
        coalesce(posting_interviews.count_interviewees, 0) as count_interviewees,

        {% if var('lever_using_requisitions', True) %}
        coalesce(posting_requisitions.count_requisitions, 0) as count_requisitions,
        posting_requisitions.posting_id is not null as has_requisition,
        {% endif %}

        {% if var('lever_using_posting_tag', True) %}
        posting_tags.tags,
        {% endif %}

        lever_user.full_name as posting_hiring_manager_name

    from posting

    left join posting_applications
        on posting.posting_id = posting_applications.posting_id
    left join posting_interviews
        on posting.posting_id = posting_interviews.posting_id

    {% if var('lever_using_requisitions', True) %}
    left join posting_requisitions
        on posting.posting_id = posting_requisitions.posting_id
    {% endif %}

    {% if var('lever_using_posting_tag', True) %}
    left join posting_tags
        on posting.posting_id = posting_tags.posting_id
    {% endif %}

    left join lever_user 
        on posting_applications.posting_hiring_manager_user_id = lever_user.user_id
)

select * from final