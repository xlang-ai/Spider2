{% macro get_media_history_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "caption", "datatype": dbt.type_string()},
    {"name": "carousel_album_id", "datatype": dbt.type_int()},
    {"name": "created_time", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "ig_id", "datatype": dbt.type_int()},
    {"name": "is_comment_enabled", "datatype": "boolean"},
    {"name": "is_story", "datatype": "boolean"},
    {"name": "media_type", "datatype": dbt.type_string()},
    {"name": "media_url", "datatype": dbt.type_string()},
    {"name": "permalink", "datatype": dbt.type_string()},
    {"name": "shortcode", "datatype": dbt.type_string()},
    {"name": "thumbnail_url", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_int()},
    {"name": "username", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
