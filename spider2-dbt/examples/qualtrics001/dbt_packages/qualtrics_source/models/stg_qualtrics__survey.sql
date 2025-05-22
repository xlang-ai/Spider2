
with base as (

    select * 
    from {{ ref('stg_qualtrics__survey_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__survey_tmp')),
                staging_columns=get_survey_columns()
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
        id as survey_id,
        survey_name,
        survey_status,
        brand_base_url,
        brand_id,
        bundle_short_name,
        composition_type,
        auto_scoring_category,
        default_scoring_category,
        division_id,
        creator_id as creator_user_id,
        owner_id as owner_user_id,
        project_category,
        project_type,
        registry_sha,
        registry_version,
        schema_version,
        scoring_summary_after_questions,
        scoring_summary_after_survey,
        scoring_summary_category,
        cast(last_accessed as {{ dbt.type_timestamp() }}) as last_accessed_at,
        cast(last_activated as {{ dbt.type_timestamp() }}) as last_activated_at,
        cast(last_modified as {{ dbt.type_timestamp() }}) as last_modified_at,
        _fivetran_deleted as is_deleted,
        _fivetran_synced,
        source_relation

        {{ fivetran_utils.fill_pass_through_columns('qualtrics__survey_pass_through_columns') }}

    from fields
)

select *
from final
