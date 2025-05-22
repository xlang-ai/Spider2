
with base as (

    select * 
    from {{ ref('stg_qualtrics__directory_mailing_list_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__directory_mailing_list_tmp')),
                staging_columns=get_directory_mailing_list_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='qualtrics_union_schemas', 
            union_database_variable='qualtrics_union_databases') 
        }}
            
    from base
),

final as (
    
    select 
        cast(creation_date as {{ dbt.type_timestamp() }}) as created_at,
        directory_id,
        id as mailing_list_id,
        cast(last_modified_date as {{ dbt.type_timestamp() }}) as last_modified_at,
        name,
        owner_id as owner_user_id,
        _fivetran_deleted as is_deleted,
        _fivetran_synced,
        source_relation

    from fields
)

select *
from final
