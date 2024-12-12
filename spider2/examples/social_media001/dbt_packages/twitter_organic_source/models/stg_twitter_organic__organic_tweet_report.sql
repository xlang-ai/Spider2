
with base as (

    select * 
    from {{ ref('stg_twitter_organic__organic_tweet_report_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_organic__organic_tweet_report_tmp')),
                staging_columns=get_organic_tweet_report_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='twitter_organic_union_schemas', 
            union_database_variable='twitter_organic_union_databases') 
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        account_id,
        app_clicks,
        card_engagements,
        carousel_swipes,
        clicks,
        date as date_day,
        engagements,
        follows,
        impressions,
        likes,
        organic_tweet_id,
        placement,
        poll_card_vote,
        qualified_impressions,
        replies,
        retweets,
        tweets_send,
        unfollows,
        url_clicks,
        video_15_s_views,
        video_3_s_100_pct_views,
        video_6_s_views,
        video_content_starts,
        video_cta_clicks,
        video_total_views,
        video_views_100,
        video_views_25,
        video_views_50,
        video_views_75,
        source_relation
    from fields
)

select * from final
