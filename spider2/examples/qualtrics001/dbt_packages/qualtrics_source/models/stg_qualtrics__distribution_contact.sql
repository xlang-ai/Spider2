
with base as (

    select * 
    from {{ ref('stg_qualtrics__distribution_contact_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__distribution_contact_tmp')),
                staging_columns=get_distribution_contact_columns()
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
        contact_frequency_rule_id,
        contact_id,
        contact_lookup_id,
        distribution_id,
        cast(opened_at as {{ dbt.type_timestamp() }}) as opened_at,
        cast(response_completed_at as {{ dbt.type_timestamp() }}) as response_completed_at,
        response_id,
        cast(response_started_at as {{ dbt.type_timestamp() }}) as response_started_at,
        cast(sent_at as {{ dbt.type_timestamp() }}) as sent_at,
        status,
        survey_link,
        survey_session_id,
        _fivetran_synced,
        source_relation

    from fields
)

select *
from final
