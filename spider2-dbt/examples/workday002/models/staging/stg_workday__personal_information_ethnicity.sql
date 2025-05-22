
with base as (

    select * 
    from {{ ref('stg_workday__personal_information_ethnicity_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_workday__personal_information_ethnicity_base')),
                staging_columns=get_personal_information_ethnicity_columns()
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
        ethnicity_code,
        ethnicity_id,
        index
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
