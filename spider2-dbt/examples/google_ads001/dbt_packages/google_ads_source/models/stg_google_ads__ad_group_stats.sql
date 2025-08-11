{{ config(enabled=var('ad_reporting__google_ads_enabled', True)) }}

with base as (

    select * 
    from {{ ref('stg_google_ads__ad_group_stats_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_google_ads__ad_group_stats_tmp')),
                staging_columns=get_ad_group_stats_columns()
            )
        }}
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='google_ads_union_schemas', 
            union_database_variable='google_ads_union_databases') 
        }}

    from base
),

final as (

    select
        source_relation,
        customer_id as account_id, 
        date as date_day, 
        cast(id as {{ dbt.type_string() }}) as ad_group_id, 
        campaign_id, 
        device,
        ad_network_type,
        coalesce(clicks, 0) as clicks, 
        coalesce(cost_micros, 0) / 1000000.0 as spend, 
        coalesce(impressions, 0) as impressions,
        coalesce(conversions, 0) as conversions,
        coalesce(conversions_value, 0) as conversions_value,
        coalesce(view_through_conversions, 0) as view_through_conversions
        
        {{ google_ads_fill_pass_through_columns(pass_through_fields=var('google_ads__ad_group_stats_passthrough_metrics'), except=['conversions', "conversions_value", "view_through_conversions"]) }}

    from fields
)

select *
from final
