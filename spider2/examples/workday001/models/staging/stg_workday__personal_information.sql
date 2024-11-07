
with base as (

    select * 
    from {{ ref('stg_workday__personal_information_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__personal_information_base')),
                staging_columns=get_personal_information_history_columns()
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
        id as worker_id,
        source_relation,
        _fivetran_synced,
        additional_nationality,
        blood_type,
        citizenship_status,
        city_of_birth,
        city_of_birth_code,
        country_of_birth,
        date_of_birth,
        date_of_death,
        gender,
        hispanic_or_latino as is_hispanic_or_latino,
        hukou_locality,
        hukou_postal_code,
        hukou_region,
        hukou_subregion,
        hukou_type,
        last_medical_exam_date,
        last_medical_exam_valid_to,
        local_hukou as is_local_hukou,
        marital_status,
        marital_status_date,
        medical_exam_notes,
        native_region,
        native_region_code,
        personnel_file_agency,
        political_affiliation,
        primary_nationality,
        region_of_birth,
        region_of_birth_code,
        religion,
        social_benefit,
        tobacco_use as is_tobacco_use,
        type
    from fields
    where {{ dbt.current_timestamp() }} between _fivetran_start and _fivetran_end
)

select *
from final
