{{ config(enabled=var('hubspot_service_enabled', False)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__ticket_pipeline_stage_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__ticket_pipeline_stage_tmp')),
                staging_columns=get_ticket_pipeline_stage_columns()
            )
        }}

    from base
),

final as (

    select
        _fivetran_deleted as is_ticket_pipeline_stage_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        active as is_active,
        display_order,
        is_closed,
        label as pipeline_stage_label,
        cast(pipeline_id as {{ dbt.type_int() }} ) as ticket_pipeline_id,
        cast(stage_id as {{ dbt.type_int() }} ) as ticket_pipeline_stage_id,
        ticket_state,
        created_at as ticket_pipeline_stage_created_at,
        updated_at as ticket_pipeline_stage_updated_at
    from fields
)

select *
from final
