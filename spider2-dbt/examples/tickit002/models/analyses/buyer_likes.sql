{{ config(materialized='table', sort='event_type', dist='like_id') }}

{%- set event_types = 'sports, theatre, concerts, jazz, classical, opera, rock, vegas, broadway, musicals' -%}

with buyers as (

    select * from {{ ref('int_buyers_extracted_from_users') }}

),

total_likes as (
        
    select
        sum(coalesce(cast(like_sports as integer), 0)) as sports,
        sum(coalesce(cast(like_theatre as integer), 0)) as theatre,
        sum(coalesce(cast(like_concerts as integer), 0)) as concerts,
        sum(coalesce(cast(like_jazz as integer), 0)) as jazz,
        sum(coalesce(cast(like_classical as integer), 0)) as classical,
        sum(coalesce(cast(like_opera as integer), 0)) as opera,
        sum(coalesce(cast(like_rock as integer), 0)) as rock,
        sum(coalesce(cast(like_vegas as integer), 0)) as vegas,
        sum(coalesce(cast(like_broadway as integer), 0)) as broadway,
        sum(coalesce(cast(like_musicals as integer), 0)) as musicals
    from
        buyers
),

final as (

    select
        row_number() over () as like_id,
        event_type,
        likes
    from
        total_likes
    unpivot 
        (
            likes for event_type in ({{ event_types }})
        )

)

select * from final