{{ config(enabled=var('social_media_rollup__facebook_enabled')) }}

with report as (

    select *
    from {{ var('facebook_posts_report') }}
    where is_most_recent_record = True

), fields as (

    select
        created_timestamp,
        cast(post_id as {{ dbt.type_string() }}) as post_id,
        post_message,
        post_url,
        page_id,
        page_name,
        'facebook' as platform,
        coalesce(sum(clicks),0) as clicks,
        coalesce(sum(impressions),0) as impressions,
        coalesce(sum(likes),0) as likes
    from report
    {{ dbt_utils.group_by(8) }}

)

select *
from fields