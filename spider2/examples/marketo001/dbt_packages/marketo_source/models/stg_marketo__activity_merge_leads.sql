with base as (

    select *
    from {{ ref('stg_marketo__activity_merge_leads_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_marketo__activity_merge_leads_tmp')),
                staging_columns=get_activity_merge_leads_columns()
            )
        }}
    from base

), fields as (

    select
        id as activity_id,
        _fivetran_synced,
        cast(activity_date as {{ dbt.type_timestamp() }}) as activity_timestamp,
        activity_type_id,
        campaign_id,
        cast(lead_id as {{ dbt.type_int() }}) as lead_id,
        master_updated,
        cast(replace(trim(trim(merge_ids,']'),'['), ',', ', ') as {{ dbt.type_string() }}) as merged_lead_id,
        merge_source,
        merged_in_sales,
        primary_attribute_value,
        primary_attribute_value_id
    from macro

)

select *
from fields


