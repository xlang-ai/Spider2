
with base as (

    select * 
    from {{ ref('stg_qualtrics__directory_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__directory_tmp')),
                staging_columns=get_directory_columns()
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
        deduplication_criteria_email as is_deduped_on_email,
        deduplication_criteria_external_data_reference as is_deduped_on_ext_ref,
        deduplication_criteria_first_name as is_deduped_on_first_name,
        deduplication_criteria_last_name as is_deduped_on_last_name,
        deduplication_criteria_phone as is_deduped_on_phone,
        id as directory_id,
        is_default,
        name,
        _fivetran_deleted as is_deleted,
        _fivetran_synced,
        source_relation

        {{ fivetran_utils.fill_pass_through_columns('qualtrics__directory_pass_through_columns') }}

    from fields
)

select *
from final
