
with base as (

    select * 
    from {{ ref('stg_twitter_organic__tweet_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_organic__tweet_tmp')),
                staging_columns=get_tweet_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='twitter_organic_union_schemas', 
            union_database_variable='twitter_organic_union_databases') 
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        account_id,
        card_uri,
        coordinates_coordinates,
        coordinates_type,
        created_at as created_timestamp,
        favorite_count,
        favorited,
        followers,
        full_text as tweet_text,
        geo_coordinates,
        geo_type,
        id as organic_tweet_id,
        {{ dbt.concat(["'https://twitter.com/p/status/'", 'id']) }} as post_url,
        in_reply_to_screen_name,
        in_reply_to_status_id,
        in_reply_to_user_id,
        lang as language,
        media_key,
        retweet_count,
        retweeted,
        source,
        truncated,
        tweet_type,
        cast(user_id as {{ dbt.type_bigint() }}) as user_id,
        source_relation
    from fields
)

select * from final
