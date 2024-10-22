
with base as (

    select * 
    from {{ ref('stg_twitter_organic__account_history_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twitter_organic__account_history_tmp')),
                staging_columns=get_account_history_columns()
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
        business_id,
        business_name,
        created_at as created_timestamp,
        deleted as is_deleted,
        id as account_id,
        industry_type,
        name as account_name,
        timezone,
        updated_at as updated_timestamp,
        source_relation
    from fields
)

select * 
from final
