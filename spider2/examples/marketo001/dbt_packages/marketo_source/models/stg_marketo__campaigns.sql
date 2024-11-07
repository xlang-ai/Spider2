{{ config(enabled=var('marketo__enable_campaigns', False)) }}

with base as (

    select *
    from {{ ref('stg_marketo__campaign_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_marketo__campaign_tmp')),
                staging_columns=get_campaign_columns()
            )
        }}
    from base

), fields as (

    select 
        active as is_active,
        created_at as created_timestamp,
        description,
        id as campaign_id,
        name as campaign_name,
        program_id,
        type as campaign_type,
        updated_at as updated_timestamp,
        workspace_name,
        computed_url,
        flow_id,
        folder_id,
        folder_type,
        is_communication_limit_enabled,
        is_requestable,
        is_system,
        max_members,
        qualification_rule_type,
        qualification_rule_interval,
        qualification_rule_unit,
        recurrence_start_at,
        recurrence_end_at,
        recurrence_interval_type,
        recurrence_interval,
        recurrence_weekday_only,
        recurrence_day_of_month,
        recurrence_day_of_week,
        recurrence_week_of_month,
        smart_list_id,
        status
    from macro
    where not coalesce(_fivetran_deleted, false)

)

select *
from fields
