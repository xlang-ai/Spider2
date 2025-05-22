
with base as (

    select * 
    from {{ ref('stg_twitter_organic__twitter_user_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_organic__twitter_user_history_tmp')),
                staging_columns=get_twitter_user_history_columns()
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
        created_at as created_timestamp,
        description as user_description,
        followers_count,
        cast(id as {{ dbt.type_bigint() }}) as user_id,
        location as user_location,
        name as user_name,
        screen_name as user_screen_name,
        source_relation
    from fields
)

select * 
from final
