{{ config(enabled=var('lever_using_requisitions', True)) }}

with base as (

    select * 
    from {{ ref('stg_lever__requisition_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__requisition_tmp')),
                staging_columns=get_requisition_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        backfill as is_backfill,
        compensation_band_currency,
        compensation_band_interval,
        compensation_band_max,
        compensation_band_min,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        creator_id as creator_user_id,
        employment_status,
        headcount_hired,
        headcount_infinite, 
        headcount_total as headcount_total_allotted,
        hiring_manager_id as hiring_manager_user_id,
        id as requisition_id,
        internal_notes,
        location as job_location,
        name as job_title,
        owner_id as owner_user_id,
        requisition_code,
        status,
        team as job_team

        {% if var('lever_requisition_passthrough_columns', []) != [] %}
        ,
        {{ var('lever_requisition_passthrough_columns', [] )  | join(', ') }}
        {% endif %}
        
    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
