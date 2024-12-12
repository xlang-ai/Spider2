with question as (

    select *
    from {{ var('question') }}
),

block_question as (

    select *
    from {{ var('block_question') }}
    where not coalesce(is_deleted, false) -- lets get rid of deleted questions
),

block as (

    select *
    from {{ var('block') }}
),

sub_question as (
    
    select *
    from {{ var('sub_question') }}
),

question_join as (

    select
        question.question_id,
        {{ dbt.split_part('question.question_id', "'#'", 1) }} as parent_question_id,
        question.question_text,
        question.survey_id,
        question.question_description,
        question.question_description_option,
        sub_question.key as sub_question_key,
        sub_question.text as sub_question_text,
        question.question_type,
        question.selector,
        question.sub_selector,
        question.is_data_hidden,
        question.is_data_private,
        question.is_deleted as is_question_deleted,
        question.validation_setting_force_response,
        question.validation_setting_force_response_type,
        question.validation_setting_type,
        question.data_export_tag,
        sub_question.choice_data_export_tag,
        block.block_id,
        block.description as block_description,
        block.randomize_questions as block_question_randomization,
        block.type as block_type,
        block.block_visibility,
        block.is_locked as is_block_locked,
        block.is_deleted as is_block_deleted,
        question.next_answer_id,
        question.next_choice_id,
        question.source_relation

    from question
    left join sub_question
        on question.question_id = sub_question.question_id {# this will fan out the grain from question_id to question_id+sub_question_key#}
        and question.survey_id = sub_question.survey_id
        and question.source_relation = sub_question.source_relation
    
    left join block_question
        on question.question_id = block_question.question_id
        and question.survey_id = block_question.survey_id
        and question.source_relation = block_question.source_relation

    left join block
        on block_question.block_id = block.block_id
        and block_question.survey_id = block.survey_id
        and block_question.source_relation = block.source_relation

)

select *
from question_join