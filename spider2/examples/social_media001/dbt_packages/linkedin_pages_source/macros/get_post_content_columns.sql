{% macro get_post_content_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "post_id", "datatype": dbt.type_string()},
    {"name": "article_description", "datatype": dbt.type_string()},
    {"name": "article_source", "datatype": dbt.type_string()},
    {"name": "article_thumbnail", "datatype": dbt.type_string()},
    {"name": "article_thumbnail_alt_text", "datatype": dbt.type_string()},
    {"name": "article_title", "datatype": dbt.type_string()},
    {"name": "carousel_id", "datatype": dbt.type_string()},
    {"name": "media_alt_text", "datatype": dbt.type_string()},
    {"name": "media_id", "datatype": dbt.type_string()},
    {"name": "media_title", "datatype": dbt.type_string()},
    {"name": "multi_image_alt_text", "datatype": dbt.type_string()},
    {"name": "poll_question", "datatype": dbt.type_string()},
    {"name": "poll_settings_duration", "datatype": dbt.type_string()},
    {"name": "poll_settings_is_voter_visible_to_author", "datatype": dbt.type_boolean()},
    {"name": "poll_settings_vote_selection_type", "datatype": dbt.type_string()},
    {"name": "poll_unique_voters_count", "datatype": dbt.type_int()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
