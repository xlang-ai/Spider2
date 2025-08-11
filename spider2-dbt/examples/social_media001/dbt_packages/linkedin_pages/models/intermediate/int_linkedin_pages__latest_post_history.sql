with ugc_post_history as (

    select *
    from {{ var('ugc_post_history_staging') }}

), is_most_recent as (

    select
        *,
        row_number() over (partition by ugc_post_id, source_relation order by last_modified_timestamp desc) = 1 as is_most_recent_record
    from ugc_post_history

)

select *
from is_most_recent
