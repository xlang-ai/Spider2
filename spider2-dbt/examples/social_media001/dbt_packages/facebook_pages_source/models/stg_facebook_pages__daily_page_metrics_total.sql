
with base as (

    select * 
    from {{ ref('stg_facebook_pages__daily_page_metrics_total_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_pages__daily_page_metrics_total_tmp')),
                staging_columns=get_daily_page_metrics_total_columns()
            )
        }}        

        {{ fivetran_utils.source_relation(
            union_schema_variable='facebook_pages_union_schemas', 
            union_database_variable='facebook_pages_union_databases') 
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        date as date_day,
        page_id,
        page_actions_post_reactions_anger_total as actions_post_reactions_anger_total,
        page_actions_post_reactions_haha_total as actions_post_reactions_haha_total,
        page_actions_post_reactions_like_total as actions_post_reactions_like_total,
        page_actions_post_reactions_love_total as actions_post_reactions_love_total,
        page_actions_post_reactions_sorry_total as actions_post_reactions_sorry_total,
        page_actions_post_reactions_wow_total as actions_post_reactions_wow_total,
        coalesce(page_actions_post_reactions_total,(page_actions_post_reactions_anger_total + page_actions_post_reactions_haha_total + page_actions_post_reactions_like_total + page_actions_post_reactions_love_total + page_actions_post_reactions_sorry_total + page_actions_post_reactions_wow_total)) as actions_post_reactions_total,
        page_fan_adds as fan_adds,
        page_fan_removes as fan_removes,
        page_fans as fans,
        page_fans_online_per_day as fans_online_per_day,
        page_impressions as impressions,
        page_impressions_nonviral as impressions_nonviral,
        page_impressions_organic as impressions_organic,
        page_impressions_paid as impressions_paid,
        page_impressions_viral as impressions_viral,
        page_negative_feedback as negative_feedback,
        page_places_checkin_total as places_checkin_total,
        page_post_engagements as post_engagements,
        page_posts_impressions as posts_impressions,
        page_posts_impressions_nonviral as posts_impressions_nonviral,
        page_posts_impressions_organic as posts_impressions_organic,
        page_posts_impressions_paid as posts_impressions_paid,
        page_posts_impressions_viral as posts_impressions_viral,
        page_total_actions as total_actions,
        page_video_complete_views_30_s as video_complete_views_30s,
        page_video_complete_views_30_s_autoplayed as video_complete_views_30s_autoplayed,
        page_video_complete_views_30_s_click_to_play as video_complete_views_30s_click_to_play,
        page_video_complete_views_30_s_organic as video_complete_views_30s_organic,
        page_video_complete_views_30_s_paid as video_complete_views_30s_paid,
        page_video_complete_views_30_s_repeat_views as video_complete_views_30s_repeat_views,
        page_video_repeat_views as video_repeat_views,
        page_video_view_time / 1000.0 as video_view_time,
        page_video_views as video_views,
        page_video_views_10_s as video_views_10s,
        page_video_views_10_s_autoplayed as video_views_10s_autoplayed,
        page_video_views_10_s_click_to_play as video_views_10s_click_to_play,
        page_video_views_10_s_organic as video_views_10s_organic,
        page_video_views_10_s_paid as video_views_10s_paid,
        page_video_views_10_s_repeat as video_views_10s_repeat,
        page_video_views_autoplayed as video_views_autoplayed,
        page_video_views_click_to_play as video_views_click_to_play,
        page_video_views_organic as video_views_organic,
        page_video_views_paid as video_views_paid,
        page_views_total as views_total,
        source_relation
    from fields
)

select * from final
