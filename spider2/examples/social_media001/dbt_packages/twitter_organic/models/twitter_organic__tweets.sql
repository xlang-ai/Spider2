with account_history as (

    select *
    from {{ ref('int_twitter_organic__latest_account') }}
    where is_most_recent_record = True

),

organic_tweet_report as (

    select *
    from {{ var('organic_tweet_report_staging') }}

),

tweet as (

    select *
    from {{ var('tweet_staging') }}

), 

users as (

    select *
    from {{ ref('int_twitter_organic__latest_user') }}
    where is_most_recent_record = True

),

joined as (

    select
        organic_tweet_report.date_day,
        tweet.organic_tweet_id,
        tweet.created_timestamp,
        tweet.tweet_text,
        tweet.account_id,
        tweet.post_url,
        account_history.account_name,
        users.user_id,
        users.user_name,
        tweet.source_relation,
        sum(organic_tweet_report.app_clicks) as app_clicks,
        sum(organic_tweet_report.card_engagements) as card_engagements,
        sum(organic_tweet_report.carousel_swipes) as carousel_swipes,
        sum(organic_tweet_report.clicks) as clicks,
        sum(organic_tweet_report.engagements) as engagements,
        sum(organic_tweet_report.follows) as follows,
        sum(organic_tweet_report.impressions) as impressions,
        sum(organic_tweet_report.likes) as likes,
        sum(organic_tweet_report.poll_card_vote) as poll_card_vote,
        sum(organic_tweet_report.qualified_impressions) as qualified_impressions,
        sum(organic_tweet_report.replies) as replies,
        sum(organic_tweet_report.retweets) as retweets,
        sum(organic_tweet_report.unfollows) as unfollows,
        sum(organic_tweet_report.url_clicks) as url_clicks,
        sum(organic_tweet_report.video_15_s_views) as video_15_s_views,
        sum(organic_tweet_report.video_3_s_100_pct_views) as video_3_s_100_pct_views,
        sum(organic_tweet_report.video_6_s_views) as video_6_s_views,
        sum(organic_tweet_report.video_content_starts) as video_content_starts,
        sum(organic_tweet_report.video_cta_clicks) as video_cta_clicks,
        sum(organic_tweet_report.video_total_views) as video_total_views,
        sum(organic_tweet_report.video_views_100) as video_views_100,
        sum(organic_tweet_report.video_views_25) as video_views_25,
        sum(organic_tweet_report.video_views_50) as video_views_50,
        sum(organic_tweet_report.video_views_75) as video_views_75
    from tweet
    left join account_history
        on tweet.account_id = account_history.account_id
        and tweet.source_relation = account_history.source_relation
    left join organic_tweet_report
        on tweet.organic_tweet_id = organic_tweet_report.organic_tweet_id
        and tweet.source_relation = organic_tweet_report.source_relation
    left join users
        on tweet.user_id = users.user_id
        and tweet.source_relation = users.source_relation
    {{ dbt_utils.group_by(10) }}

)

select *
from joined