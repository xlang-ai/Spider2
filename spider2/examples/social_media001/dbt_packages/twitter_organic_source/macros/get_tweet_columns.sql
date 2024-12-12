{% macro get_tweet_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "card_uri", "datatype": dbt.type_string()},
    {"name": "coordinates_coordinates", "datatype": dbt.type_string()},
    {"name": "coordinates_type", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "favorite_count", "datatype": dbt.type_int()},
    {"name": "favorited", "datatype": "boolean"},
    {"name": "followers", "datatype": "boolean"},
    {"name": "full_text", "datatype": dbt.type_string()},
    {"name": "geo_coordinates", "datatype": dbt.type_string()},
    {"name": "geo_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "in_reply_to_screen_name", "datatype": dbt.type_string()},
    {"name": "in_reply_to_status_id", "datatype": dbt.type_string()},
    {"name": "in_reply_to_user_id", "datatype": dbt.type_string()},
    {"name": "lang", "datatype": dbt.type_string()},
    {"name": "media_key", "datatype": dbt.type_string()},
    {"name": "retweet_count", "datatype": dbt.type_int()},
    {"name": "retweeted", "datatype": "boolean"},
    {"name": "source", "datatype": dbt.type_string()},
    {"name": "truncated", "datatype": "boolean"},
    {"name": "tweet_type", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
