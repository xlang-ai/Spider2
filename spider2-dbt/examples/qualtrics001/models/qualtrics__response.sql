with response as (
    -- will probably move the logic from this int model to the end model directly 
    select *
    from {{ ref('int_qualtrics__responses') }}
),

question_option as (

    select *
    from {{ var('question_option') }}
),

question as (

    select *
    from {{ ref('int_qualtrics__question') }}
),

survey as (

    select *
    from {{ var('survey') }}
),

embedded_data as (

    select *
    from {{ ref('int_qualtrics__survey_embedded_data') }}
),

contacts as (

    select *
    from {{ ref('int_qualtrics__contacts') }}
),

rollup_contacts as (

    select 
        email,
        source_relation,
        max(email_domain) as email_domain,
        max(first_name) as first_name,
        max(last_name) as last_name,
        max(language) as language,
        max(external_data_reference) as external_data_reference,
        {{ fivetran_utils.max_bool(boolean_field="is_xm_directory_contact") }} as is_xm_directory_contact,
        {{ fivetran_utils.max_bool(boolean_field="is_research_core_contact") }} as is_research_core_contact

    from contacts
    group by 1,2
),

final as (

    select 
        response.*,
        question_option.recode_value,
        question_option.text as question_option_text,
        rollup_contacts.first_name,
        rollup_contacts.last_name,
        rollup_contacts.email_domain,
        rollup_contacts.language as contact_language,
        rollup_contacts.external_data_reference as contact_external_data_reference,
        rollup_contacts.is_xm_directory_contact,
        rollup_contacts.is_research_core_contact,

        embedded_data.embedded_data,
        survey.survey_name,
        survey.survey_status,
        survey.project_category,
        survey.project_type,
        survey.brand_base_url,
        
        -- most question fields are included, as there is no question end model. join with `int_qualtrics__question` to bring in more
        question.question_description,
        question.question_type,
        question.block_id,
        question.block_description,
        question.block_question_randomization,
        question.block_type,
        question.block_visibility,
        question.validation_setting_force_response,
        question.validation_setting_force_response_type,
        question.validation_setting_type,
        question.is_question_deleted,
        question.is_block_deleted

    from response

    left join question
        on response.question_id = question.question_id
        and response.survey_id = question.survey_id
        and response.sub_question_key = question.sub_question_key
        and response.source_relation = question.source_relation

    left join question_option
        on response.question_id = question_option.question_id 
        and response.survey_id = question_option.survey_id
        and response.question_option_key = question_option.key
        and response.source_relation = question_option.source_relation

    left join survey
        on response.survey_id = survey.survey_id
        and response.source_relation = survey.source_relation

    left join embedded_data
        on response.survey_response_id = embedded_data.response_id
        and response.source_relation = embedded_data.source_relation

    left join rollup_contacts 
        on response.recipient_email = rollup_contacts.email
        and response.source_relation = rollup_contacts.source_relation

)

select *
from final