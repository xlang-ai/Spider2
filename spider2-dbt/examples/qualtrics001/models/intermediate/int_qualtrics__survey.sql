with survey as (

    select *
    from {{ var('survey') }}
),

qualtrics_user as (

    select *
    from {{ var('user') }}
),

survey_version as (

    select *
    from {{ var('survey_version') }}
),

latest_version as (

    select *
    from survey_version 
    where is_published
),

agg_versions as (

    select 
        survey_id,
        source_relation,
        count(distinct version_number) as count_published_versions
    from survey_version
    where was_published and not is_deleted
    group by 1,2
),

survey_join as (

    select

        survey.*,
        latest_version.version_id,
        latest_version.version_number,
        latest_version.version_description,
        latest_version.created_at as survey_version_created_at,
        agg_versions.count_published_versions,
        latest_version.publisher_user_id,
        version_publisher.email as publisher_email, 
        creator.email as creator_email,
        owner.email as owner_email

    from survey
    left join latest_version
        on survey.survey_id = latest_version.survey_id
        and survey.source_relation = latest_version.source_relation
    left join qualtrics_user as version_publisher
        on latest_version.publisher_user_id = version_publisher.user_id
        and latest_version.source_relation = version_publisher.source_relation
    left join qualtrics_user as owner
        on survey.owner_user_id = owner.user_id
        and survey.source_relation = owner.source_relation
    left join qualtrics_user as creator
        on survey.creator_user_id = creator.user_id
        and survey.source_relation = creator.source_relation
    left join agg_versions 
        on survey.survey_id = agg_versions.survey_id
        and survey.source_relation = agg_versions.source_relation
)

select *
from survey_join