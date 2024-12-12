{% macro get_guide_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_string()},
    {"name": "attribute_badge_can_change_badge_color", "datatype": "boolean"},
    {"name": "attribute_badge_color", "datatype": dbt.type_string()},
    {"name": "attribute_badge_height", "datatype": dbt.type_int()},
    {"name": "attribute_badge_image_url", "datatype": dbt.type_string()},
    {"name": "attribute_badge_is_only_show_once", "datatype": "boolean"},
    {"name": "attribute_badge_name", "datatype": dbt.type_string()},
    {"name": "attribute_badge_offset_left", "datatype": dbt.type_int()},
    {"name": "attribute_badge_offset_right", "datatype": dbt.type_int()},
    {"name": "attribute_badge_offset_top", "datatype": dbt.type_int()},
    {"name": "attribute_badge_position", "datatype": dbt.type_string()},
    {"name": "attribute_badge_show_on_event", "datatype": dbt.type_string()},
    {"name": "attribute_badge_use_hover", "datatype": dbt.type_string()},
    {"name": "attribute_badge_width", "datatype": dbt.type_int()},
    {"name": "attribute_device_type", "datatype": dbt.type_string()},
    {"name": "attribute_priority", "datatype": dbt.type_string()},
    {"name": "attribute_type", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "created_by_user_id", "datatype": dbt.type_string()},
    {"name": "email_state", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "is_multi_step", "datatype": "boolean"},
    {"name": "is_training", "datatype": "boolean"},
    {"name": "last_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "last_updated_by_user_id", "datatype": dbt.type_string()},
    {"name": "launch_method", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "published_at", "datatype": dbt.type_timestamp()},
    {"name": "recurrence", "datatype": dbt.type_int()},
    {"name": "recurrence_eligibility_window", "datatype": dbt.type_int()},
    {"name": "reset_at", "datatype": dbt.type_timestamp()},
    {"name": "root_version_id", "datatype": dbt.type_string()},
    {"name": "stable_version_id", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
