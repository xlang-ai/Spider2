
with base as (

    select * 
    from {{ ref('stg_instagram_business__media_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_instagram_business__media_history_tmp')),
                staging_columns=get_media_history_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='instagram_business_union_schemas', 
            union_database_variable='instagram_business_union_databases') 
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_id,
        _fivetran_synced,
        caption as post_caption,
        carousel_album_id,
        created_time as created_timestamp,
        id as post_id,
        ig_id,
        is_comment_enabled,
        is_story,
        media_type,
        media_url,
        permalink as post_url,
        shortcode,
        thumbnail_url,
        user_id,
        username,
        source_relation
    from fields
),

is_most_recent as (

    select 
        *,
        row_number() over (partition by post_id, source_relation order by _fivetran_synced desc) = 1 as is_most_recent_record
    from final

)

select * from is_most_recent
