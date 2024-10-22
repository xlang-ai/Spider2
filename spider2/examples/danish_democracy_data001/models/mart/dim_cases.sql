with

case_steps as (
    select * from {{ ref('stg_case_steps') }}
),

case_step_types as (
    select * from {{ ref('stg_case_step_types') }}
),

case_step_statuses as (
    select * from {{ ref('stg_case_step_statuses') }}
),

cases as (
    select * from {{ ref('stg_cases') }}
),

case_type as (
    select * from {{ ref('stg_case_types') }}
),

case_statuses as (
    select * from {{ ref('stg_case_statuses') }}
),

case_categories as (
    select * from {{ ref('stg_case_categories') }}
),

final as (
    select
        -- key
        {{ dbt_utils.generate_surrogate_key(
            ['case_steps.case_step_id']
        ) }} as case_sk,

        -- attributes
        case_type.case_type,
        case_categories.case_category,
        case_statuses.case_status,
        cases.case_short_title,
        cases.case_number,
        cases.case_number_prefix,
        cases.case_number_numeric,
        cases.case_number_postfix,
        cases.case_period_id,
        cases.case_decision_result_code,
        cases.case_state_budget,
        cases.case_reason,
        cases.case_paragraph_number,
        cases.case_decision_date,
        cases.case_decision,
        case_step_statuses.case_step_status,
        case_steps.case_step_title,
        case_step_types.case_step_type,

        -- meta
        case_steps.case_step_updated_at,
        case_step_types.case_step_type_updated_at,
        case_step_statuses.case_step_status_updated_at,
        cases.case_updated_at
    from case_steps
    left join case_step_types
        on case_steps.case_step_type_id = case_step_types.case_step_type_id
    left join case_step_statuses
        on case_steps.case_step_status_id = case_step_statuses.case_step_status_id --noqa: LT05
    left join cases
        on case_steps.case_id = cases.case_id
    left join case_type
        on cases.case_type_id = case_type.case_type_id
    left join case_statuses
        on cases.case_status_id = case_statuses.case_status_id
    left join case_categories
        on cases.case_category_id = case_categories.case_category_id
)

select * from final
