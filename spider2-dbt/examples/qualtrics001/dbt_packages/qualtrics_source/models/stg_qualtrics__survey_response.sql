
with base as (

    select * 
    from {{ ref('stg_qualtrics__survey_response_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__survey_response_tmp')),
                staging_columns=get_survey_response_columns()
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
        distribution_channel,
        duration_in_seconds,
        cast(end_date as {{ dbt.type_timestamp() }}) as finished_at,
        cast(case when finished = 1 then true else false end as {{ dbt.type_boolean() }}) as is_finished,
        id as response_id,
        ip_address,
        cast(last_modified_date as {{ dbt.type_timestamp() }}) as last_modified_at,
        location_latitude,
        location_longitude,
        progress,
        lower(recipient_email) as recipient_email,
        recipient_first_name,
        recipient_last_name,
        cast(recorded_date as {{ dbt.type_timestamp() }}) as recorded_date,
        cast(start_date as {{ dbt.type_timestamp() }}) as started_at,
        status,
        survey_id,
        user_language,
        _fivetran_synced,
        source_relation
        
    from fields
)

select *
from final
