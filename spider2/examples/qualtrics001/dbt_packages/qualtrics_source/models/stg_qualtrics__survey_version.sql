
with base as (

    select * 
    from {{ ref('stg_qualtrics__survey_version_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__survey_version_tmp')),
                staging_columns=get_survey_version_columns()
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
        description as version_description,
        id as version_id,
        published as is_published,
        survey_id,
        user_id as publisher_user_id,
        version_number,
        was_published,
        _fivetran_deleted as is_deleted,
        _fivetran_synced,
        source_relation
        
    from fields
)

select *
from final
