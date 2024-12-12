with posts as (
    
    select *
    from {{ var('posts') }}

), most_recent_posts as (

    select
        *,
        row_number() over (partition by post_id, source_relation order by _fivetran_synced desc) = 1 as is_most_recent_record
    from posts
)

select *
from most_recent_posts