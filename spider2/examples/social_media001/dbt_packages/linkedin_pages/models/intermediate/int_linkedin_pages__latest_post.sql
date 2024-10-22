with ugc_post as (

    select *
    from {{ var('ugc_post_share_statistic_staging') }}

), is_most_recent as (

    select 
        *,
        row_number() over (partition by ugc_post_id, source_relation order by _fivetran_synced desc) = 1 as is_most_recent_record
    from ugc_post

)

select *
from is_most_recent