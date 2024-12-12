
with base as (

    select * 
    from {{ ref('stg_instagram_business__user_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_instagram_business__user_history_tmp')),
                staging_columns=get_user_history_columns()
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
        followers_count,
        follows_count,
        id as user_id,
        ig_id,
        media_count,
        name as account_name,
        username,
        website,
        source_relation
    from fields
),

is_most_recent as (

    select 
        *,
        row_number() over (partition by user_id, source_relation order by _fivetran_synced desc) = 1 as is_most_recent_record
    from final

)

select * from is_most_recent
