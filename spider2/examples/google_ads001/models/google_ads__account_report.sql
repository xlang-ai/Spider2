{{ config(enabled=var('ad_reporting__google_ads_enabled', True)) }}

with stats as (

    select *
    from {{ var('account_stats') }}
), 

accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = True
), 

fields as (

    select
        stats.source_relation,
        stats.date_day,
        accounts.account_name,
        stats.account_id,
        accounts.currency_code,
        accounts.auto_tagging_enabled,
        accounts.time_zone,
        sum(stats.spend) as spend,
        sum(stats.clicks) as clicks,
        sum(stats.impressions) as impressions,
        sum(stats.conversions) as conversions,
        sum(stats.conversions_value) as conversions_value,
        sum(stats.view_through_conversions) as view_through_conversions

        {{ google_ads_persist_pass_through_columns(pass_through_variable='google_ads__account_stats_passthrough_metrics', identifier='stats', transform='sum', coalesce_with=0, exclude_fields=['conversions','conversions_value','view_through_conversions']) }}

    from stats
    left join accounts
        on stats.account_id = accounts.account_id
        and stats.source_relation = accounts.source_relation
    {{ dbt_utils.group_by(7) }}
)

select *
from fields