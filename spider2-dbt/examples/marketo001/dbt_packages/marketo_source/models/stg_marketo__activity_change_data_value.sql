with base as (

    select *
    from {{ ref('stg_marketo__activity_change_data_value_tmp') }}

), macro as (

    select 
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_marketo__activity_change_data_value_tmp')),
                staging_columns=get_activity_change_data_value_columns()
            )
        }}
    from base

), fields as (

    select 
        cast(activity_date as {{ dbt.type_timestamp() }}) as activity_timestamp,
        activity_type_id,
        api_method_name,
        campaign_id,
        id as activity_id,
        lead_id,
        modifying_user as modifying_user_id,
        new_value,
        old_value,
        primary_attribute_value,
        primary_attribute_value_id,
        reason as change_reason,
        request_id,
        source as change_source
    from macro

)

select *
from fields
