
with base as (

    select * 
    from {{ ref('stg_linkedin_pages__ugc_post_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_linkedin_pages__ugc_post_history_tmp')),
                staging_columns=get_ugc_post_history_columns()
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
        _fivetran_synced,
        author as post_author,
        commentary,
        created_actor,
        created_time as created_timestamp,
        first_published_at as first_published_timestamp,
        cast(case when lower(id) like '%urn:li:share:%' 
                then replace(id, 'urn:li:share:', '')
            when lower(id) like '%urn:li:ugcpost:%'
                then replace(lower(id), 'urn:li:ugcpost:', '')
            else id end
            as {{ dbt.type_string() }}) as ugc_post_id,
        id as ugc_post_urn,
        -- This generates an 'embed' URL. I can't get normal URLs working.
        {{ dbt.concat(["'https://www.linkedin.com/embed/feed/update/'", "id"]) }} as post_url,
        last_modified_actor,
        last_modified_time as last_modified_timestamp,
        lifecycle_state,
        visibility,
        source_relation

    from fields
)

select * from final
