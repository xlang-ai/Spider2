{% macro get_ugc_post_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "author", "datatype": dbt.type_string()},
    {"name": "commentary", "datatype": dbt.type_string()},
    {"name": "container_entity", "datatype": dbt.type_string()},
    {"name": "created_actor", "datatype": dbt.type_string()},
    {"name": "created_time", "datatype": dbt.type_timestamp()},
    {"name": "distribution_external_distribution_channels", "datatype": dbt.type_string()},
    {"name": "distribution_feed_distribution", "datatype": dbt.type_string()},
    {"name": "first_published_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_modified_actor", "datatype": dbt.type_string()},
    {"name": "last_modified_time", "datatype": dbt.type_timestamp()},
    {"name": "lifecycle_state", "datatype": dbt.type_string()},
    {"name": "response_context_parent", "datatype": dbt.type_string()},
    {"name": "response_context_root", "datatype": dbt.type_string()},
    {"name": "visibility", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}