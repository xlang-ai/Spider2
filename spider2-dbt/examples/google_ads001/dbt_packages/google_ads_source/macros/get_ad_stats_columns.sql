{% macro get_ad_stats_columns() %}

{% set columns = [
    {"name": "ad_group", "datatype": dbt.type_string()},
    {"name": "ad_group_id", "datatype": dbt.type_string()},
    {"name": "ad_id", "datatype": dbt.type_int()},
    {"name": "ad_network_type", "datatype": dbt.type_string()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "clicks", "datatype": dbt.type_int()},
    {"name": "cost_micros", "datatype": dbt.type_int()},
    {"name": "customer_id", "datatype": dbt.type_int()},
    {"name": "date", "datatype": "date"},
    {"name": "device", "datatype": dbt.type_string()},
    {"name": "impressions", "datatype": dbt.type_int()},
    {"name": "keyword_ad_group_criterion", "datatype": dbt.type_string()},
    {"name": "conversions", "datatype": dbt.type_int()},
    {"name": "conversions_value", "datatype": dbt.type_int()},
    {"name": "view_through_conversions", "datatype": dbt.type_int()}
] %}

{# Doing it this way in case users were bringing in conversion metrics via passthrough columns prior to us adding them by default #}
{{ google_ads_add_pass_through_columns(base_columns=columns, pass_through_fields=var('google_ads__ad_stats_passthrough_metrics'), except_fields=['conversions', "conversions_value", "view_through_conversions"]) }}

{{ return(columns) }}

{% endmacro %}