with share_statistic as (

    select *
    from {{ var('share_statistic_staging') }}

),

ugc_post_share_statistic as (

    select *
    from {{ ref('int_linkedin_pages__latest_post') }}
    where is_most_recent_record = true

),

ugc_post_history as (

    select *
    from {{ ref('int_linkedin_pages__latest_post_history') }}
    where is_most_recent_record = true

),

post_content as (

    select *
    from {{ var('post_content') }}

),

organization as (

    select *
    from {{ var('organization_staging') }}

),

organization_ugc_post as (

    select *
    from {{ var('organization_ugc_post_staging') }}

),

joined as (

    select
        ugc_post_history.ugc_post_id,
        ugc_post_history.post_author,
        ugc_post_history.post_url,
        ugc_post_history.created_timestamp,
        ugc_post_history.first_published_timestamp,
        ugc_post_history.lifecycle_state,
        ugc_post_history.commentary,
        organization.organization_id,
        coalesce(post_content.article_title, post_content.media_title) as post_title,
        post_content.post_type,
        organization.organization_name,
        share_statistic.click_count,
        share_statistic.comment_count,
        share_statistic.impression_count,
        share_statistic.like_count,
        share_statistic.share_count,
        ugc_post_history.source_relation
    from ugc_post_history
    left join ugc_post_share_statistic
        on ugc_post_share_statistic.ugc_post_id = ugc_post_history.ugc_post_id
        and ugc_post_share_statistic.source_relation = ugc_post_history.source_relation
    left join share_statistic
        on share_statistic.share_statistic_id = ugc_post_share_statistic.share_statistic_id
        and share_statistic.source_relation = ugc_post_share_statistic.source_relation
    left join post_content
        on ugc_post_history.ugc_post_urn = post_content.ugc_post_urn
        and ugc_post_history.source_relation = post_content.source_relation
    left join organization_ugc_post
        on ugc_post_history.ugc_post_id = organization_ugc_post.ugc_post_id
        and ugc_post_history.source_relation = organization_ugc_post.source_relation
    left join organization
        on organization_ugc_post.organization_id = organization.organization_id
        and organization_ugc_post.source_relation = organization.source_relation

)

select *
from joined
