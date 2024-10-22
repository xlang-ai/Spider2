
with base as (

    select * 
    from {{ ref('stg_instagram_business__media_insights_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_instagram_business__media_insights_tmp')),
                staging_columns=get_media_insights_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='instagram_business_union_schemas', 
            union_database_variable='instagram_business_union_databases') 
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_id,
        _fivetran_synced,
        carousel_album_engagement,
        carousel_album_impressions,
        carousel_album_reach,
        carousel_album_saved,
        carousel_album_video_views,
        comment_count,
        id as post_id,
        like_count,
        story_exits,
        story_impressions,
        story_reach,
        story_replies,
        story_taps_back,
        story_taps_forward,
        video_photo_engagement,
        video_photo_impressions,
        video_photo_reach,
        video_photo_saved,
        video_views,
        reel_comments,
        reel_likes,
        reel_plays,
        reel_reach,
        reel_shares,
        reel_total_interactions,
        source_relation
    from fields
),

is_most_recent as (

    select 
        *,
        row_number() over (partition by post_id, source_relation order by _fivetran_synced desc) = 1 as is_most_recent_record
    from final

)

select * from is_most_recent
