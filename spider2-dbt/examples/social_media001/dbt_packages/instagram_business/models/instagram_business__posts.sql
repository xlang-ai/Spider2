with media_history as (

    select *
    from {{ var('media_history_staging') }}
    where is_most_recent_record = true

), media_insights as (

    select *
    from {{ var('media_insights_staging') }}
    where is_most_recent_record = true

), user_history as (

    select *
    from {{ var('user_history_staging') }}
    where is_most_recent_record = true

), joined as (

    select 
        user_history.account_name,
        user_history.user_id,
        media_history.post_caption,
        media_history.created_timestamp,
        media_history.post_id,
        media_history.is_comment_enabled,
        media_history.is_story,
        media_history.media_type,
        media_history.media_url,
        media_history.post_url,
        media_history.shortcode,
        media_history.thumbnail_url,
        media_history.username,
        media_insights.carousel_album_engagement,
        media_insights.carousel_album_impressions,
        media_insights.carousel_album_reach,
        media_insights.carousel_album_saved,
        media_insights.carousel_album_video_views,
        media_insights.comment_count,
        media_insights.like_count,
        media_insights.story_exits,
        media_insights.story_impressions,
        media_insights.story_reach,
        media_insights.story_replies,
        media_insights.story_taps_back,
        media_insights.story_taps_forward,
        media_insights.video_photo_engagement,
        media_insights.video_photo_impressions,
        media_insights.video_photo_reach,
        media_insights.video_photo_saved,
        media_insights.video_views,
        media_insights.reel_comments,
        media_insights.reel_likes,
        media_insights.reel_plays,
        media_insights.reel_reach,
        media_insights.reel_shares,
        media_insights.reel_total_interactions,
        media_history.source_relation
    from media_history
    left join media_insights
        on media_history.post_id = media_insights.post_id
        and media_history.source_relation = media_insights.source_relation
    left join user_history
        on media_history.user_id = user_history.user_id
        and media_history.source_relation = user_history.source_relation

)

select *
from joined
