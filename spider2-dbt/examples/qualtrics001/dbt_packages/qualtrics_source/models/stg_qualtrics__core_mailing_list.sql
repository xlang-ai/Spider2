{{ config(enabled=var('qualtrics__using_core_mailing_lists', false)) }}

with base as (

    select * 
    from {{ ref('stg_qualtrics__core_mailing_list_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__core_mailing_list_tmp')),
                staging_columns=get_core_mailing_list_columns()
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
        id as mailing_list_id,
        library_id,
        name,
        category,
        folder,
        _fivetran_deleted as is_deleted,
        _fivetran_synced,
        source_relation

    from fields
)

select *
from final
