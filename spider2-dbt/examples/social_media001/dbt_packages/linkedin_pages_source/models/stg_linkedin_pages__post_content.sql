
with base as (

    select * 
    from {{ ref('stg_linkedin_pages__post_content_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_linkedin_pages__post_content_tmp')),
                staging_columns=get_post_content_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='linkedin_pages_union_schemas', 
            union_database_variable='linkedin_pages_union_databases') 
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_id,
        _fivetran_synced,
        post_id as ugc_post_urn,
        article_description,
        article_source,
        article_thumbnail,
        article_thumbnail_alt_text,
        cast(article_title as {{ dbt.type_string() }}) as article_title,
        carousel_id,
        media_alt_text,
        media_id,
        cast(media_title as {{ dbt.type_string() }}) as media_title,
        multi_image_alt_text,
        poll_question,
        poll_settings_duration,
        poll_settings_is_voter_visible_to_author,
        poll_settings_vote_selection_type,
        poll_unique_voters_count,
        type as post_type,
        source_relation
    from fields
)

select * 
from final
