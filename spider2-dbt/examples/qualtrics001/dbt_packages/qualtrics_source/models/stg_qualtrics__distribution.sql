
with base as (

    select * 
    from {{ ref('stg_qualtrics__distribution_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__distribution_tmp')),
                staging_columns=get_distribution_columns()
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
        cast(created_date as {{ dbt.type_timestamp() }}) as created_at,
        header_from_email,
        header_from_name,
        header_reply_to_email,
        header_subject,
        id as distribution_id,
        message_library_id,
        message_message_id as message_id,
        message_message_text as message_text,
        cast(modified_date as {{ dbt.type_timestamp() }}) as last_modified_at,
        organization_id,
        owner_id as owner_user_id,
        parent_distribution_id,
        recipient_contact_id,
        recipient_library_id,
        recipient_mailing_list_id,
        recipient_sample_id,
        request_status,
        request_type,
        cast(send_date as {{ dbt.type_timestamp() }}) as send_at,
        cast(survey_link_expiration_date as {{ dbt.type_timestamp() }}) as survey_link_expires_at,
        survey_link_link_type as survey_link_type,
        survey_link_survey_id as survey_id,
        _fivetran_deleted as is_deleted,
        _fivetran_synced,
        source_relation

        {{ fivetran_utils.fill_pass_through_columns('qualtrics__distribution_pass_through_columns') }}

    from fields
)

select *
from final
