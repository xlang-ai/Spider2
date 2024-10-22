with pages as (

    select *
    from {{ var('pages') }}

), page_metrics as (

    select *
    from {{ var('page_metrics') }}

), joined as (

    select 
        page_metrics.date_day,
        pages.page_id,
        pages.page_name,
        page_metrics.actions_post_reactions_total,
        page_metrics.fan_adds,
        page_metrics.fan_removes,
        page_metrics.impressions,
        page_metrics.post_engagements,
        page_metrics.posts_impressions,
        page_metrics.video_complete_views_30s,
        page_metrics.video_views,
        page_metrics.video_views_10s,
        page_metrics.views_total,    
        page_metrics.source_relation
    from page_metrics
    left join pages
        on page_metrics.page_id = pages.page_id
        and page_metrics.source_relation = pages.source_relation

)

select *
from joined