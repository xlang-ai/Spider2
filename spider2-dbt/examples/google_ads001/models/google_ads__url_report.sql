{{ config(enabled=var('ad_reporting__google_ads_enabled', True)) }}

with stats as (

    select *
    from {{ var('ad_stats') }}
), 

accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = True
), 

campaigns as (

    select *
    from {{ var('campaign_history') }}
    where is_most_recent_record = True
), 

ad_groups as (

    select *
    from {{ var('ad_group_history') }}
    where is_most_recent_record = True
),

ads as (

    select *
    from {{ var('ad_history') }}
    where is_most_recent_record = True
), 

fields as (

    select
        stats.source_relation,
        stats.date_day,
        accounts.account_name,
        accounts.account_id,
        accounts.currency_code,
        campaigns.campaign_name,
        campaigns.campaign_id,
        ad_groups.ad_group_name,
        stats.ad_group_id,
        stats.ad_id,
        ads.base_url,
        ads.url_host,
        ads.url_path,

        {% if var('google_auto_tagging_enabled', false) %}

        coalesce( {{ google_ads_source.google_ads_extract_url_parameter('ads.final_url', 'utm_source') }} , 'google')  as utm_source,
        coalesce( {{ google_ads_source.google_ads_extract_url_parameter('ads.final_url', 'utm_medium') }} , 'cpc') as utm_medium,
        coalesce( {{ google_ads_source.google_ads_extract_url_parameter('ads.final_url', 'utm_campaign') }} , campaigns.campaign_name) as utm_campaign,
        coalesce( {{ google_ads_source.google_ads_extract_url_parameter('ads.final_url', 'utm_content') }} , ad_groups.ad_group_name) as utm_content,

        {% else %}

        ads.utm_source,
        ads.utm_medium,
        ads.utm_campaign,
        ads.utm_content,
        
        {% endif %}

        ads.utm_term,
        sum(stats.spend) as spend,
        sum(stats.clicks) as clicks,
        sum(stats.impressions) as impressions,
        sum(conversions) as conversions,
        sum(conversions_value) as conversions_value,
        sum(view_through_conversions) as view_through_conversions

        {{ google_ads_persist_pass_through_columns(pass_through_variable='google_ads__ad_stats_passthrough_metrics', identifier='stats', transform='sum', coalesce_with=0, exclude_fields=['conversions','conversions_value','view_through_conversions']) }}

    from stats
    left join ads
        on stats.ad_id = ads.ad_id
        and stats.source_relation = ads.source_relation
        and stats.ad_group_id = ads.ad_group_id
    left join ad_groups
        on ads.ad_group_id = ad_groups.ad_group_id
        and ads.source_relation = ad_groups.source_relation
    left join campaigns
        on ad_groups.campaign_id::string = campaigns.campaign_id::string
        and ad_groups.source_relation = campaigns.source_relation
    left join accounts
        on campaigns.account_id = accounts.account_id
        and campaigns.source_relation = accounts.source_relation

    {% if var('ad_reporting__url_report__using_null_filter', True) %}
        where ads.source_final_urls is not null
    {% endif %}

    {{ dbt_utils.group_by(18) }}
)

select *
from fields