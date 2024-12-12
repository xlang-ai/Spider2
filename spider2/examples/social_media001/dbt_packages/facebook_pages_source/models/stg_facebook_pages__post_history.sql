
with base as (

    select * 
    from {{ ref('stg_facebook_pages__post_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_pages__post_history_tmp')),
                staging_columns=get_post_history_columns()
            )
        }}
                
        {{ fivetran_utils.source_relation(
            union_schema_variable='facebook_pages_union_schemas', 
            union_database_variable='facebook_pages_union_databases') 
        }}
        
    from base
),

final as (
    
    select
        _fivetran_synced,
        allowed_advertising_objects,
        created_time as created_timestamp,
        id as post_id,
        is_eligible_for_promotion,
        is_hidden,
        is_instagram_eligible,
        is_published,
        message as post_message,
        page_id,
        parent_id,
        privacy_allow,
        privacy_deny,
        privacy_description,
        privacy_friends,
        privacy_value,
        promotable_id,
        share_count,
        status_type,
        updated_time as updated_timestamp,
        concat(
            'https://facebook.com/', 
            split_part(cast(id as varchar), '_', 1), 
            '/posts/', 
            split_part(cast(id as varchar), '_', 2)
        ) as post_url,
        source_relation
    from fields
)

select * 
from final
