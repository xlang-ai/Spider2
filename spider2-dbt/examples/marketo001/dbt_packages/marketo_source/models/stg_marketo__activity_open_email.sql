with base as (

    select *
    from {{ ref('stg_marketo__activity_open_email_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_marketo__activity_open_email_tmp')),
                staging_columns=get_activity_open_email_columns()
            )
        }}
    from base

), fields as (

    select 
        cast(activity_date as {{ dbt.type_timestamp() }}) as activity_timestamp,
        activity_type_id,
        campaign_id,
        campaign_run_id,
        choice_number,
        device,
        email_template_id,
        id as activity_id,
        is_mobile_device,
        lead_id,
        platform,
        primary_attribute_value,
        primary_attribute_value_id,
        step_id,
        user_agent
    from macro

), surrogate as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['primary_attribute_value_id','campaign_id','campaign_run_id','lead_id']) }} as email_send_id
    from fields

)

select *
from surrogate


