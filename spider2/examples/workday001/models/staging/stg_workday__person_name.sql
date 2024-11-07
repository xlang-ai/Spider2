
with base as (

    select * 
    from {{ ref('stg_workday__person_name_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__person_name_base')),
                staging_columns=get_person_name_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='workday_union_schemas', 
            union_database_variable='workday_union_databases') 
        }}
    from base
),

final as (
    
    select 
        personal_info_system_id as worker_id,
        source_relation,
        _fivetran_synced,
        academic_suffix,
        additional_name_type,
        country,
        first_name,
        full_name_singapore_malaysia,
        hereditary_suffix,
        honorary_suffix,
        index,
        last_name,
        local_first_name,
        local_first_name_2,
        local_last_name,
        local_last_name_2,
        local_middle_name,
        local_middle_name_2,
        local_secondary_last_name,
        local_secondary_last_name_2,
        middle_name,
        prefix_salutation,
        prefix_title,
        prefix_title_code,
        professional_suffix,
        religious_suffix,
        royal_suffix,
        secondary_last_name,
        social_suffix,
        social_suffix_id,
        tertiary_last_name,
        type as person_name_type
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
