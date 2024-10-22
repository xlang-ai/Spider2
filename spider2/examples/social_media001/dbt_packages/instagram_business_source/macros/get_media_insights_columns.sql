{% macro get_media_insights_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "carousel_album_engagement", "datatype": dbt.type_int()},
    {"name": "carousel_album_impressions", "datatype": dbt.type_int()},
    {"name": "carousel_album_reach", "datatype": dbt.type_int()},
    {"name": "carousel_album_saved", "datatype": dbt.type_int()},
    {"name": "carousel_album_video_views", "datatype": dbt.type_int()},
    {"name": "comment_count", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "like_count", "datatype": dbt.type_int()},
    {"name": "story_exits", "datatype": dbt.type_int()},
    {"name": "story_impressions", "datatype": dbt.type_int()},
    {"name": "story_reach", "datatype": dbt.type_int()},
    {"name": "story_replies", "datatype": dbt.type_int()},
    {"name": "story_taps_back", "datatype": dbt.type_int()},
    {"name": "story_taps_forward", "datatype": dbt.type_int()},
    {"name": "video_photo_engagement", "datatype": dbt.type_int()},
    {"name": "video_photo_impressions", "datatype": dbt.type_int()},
    {"name": "video_photo_reach", "datatype": dbt.type_int()},
    {"name": "video_photo_saved", "datatype": dbt.type_int()},
    {"name": "video_views", "datatype": dbt.type_int()},
    {"name": "reel_comments", "datatype": dbt.type_int()},
    {"name": "reel_likes", "datatype": dbt.type_int()},
    {"name": "reel_plays", "datatype": dbt.type_int()},
    {"name": "reel_reach", "datatype": dbt.type_int()},
    {"name": "reel_shares", "datatype": dbt.type_int()},
    {"name": "reel_total_interactions", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
