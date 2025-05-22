{{ config(enabled=var('marketo__enable_campaigns', False) and var('marketo__enable_programs', False)) }}

with base as (

    select *
    from {{ ref('stg_marketo__program_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_marketo__program_tmp')),
                staging_columns=get_program_columns()
            )
        }}
    from base

), fields as (

    select
        id as program_id,
        channel,
        created_at as created_timestamp,
        description,
        end_date as end_timestamp,
        name as program_name,
        sfdc_id,
        sfdc_name,
        start_date as start_timestamp,
        status as program_status,
        type as program_type,
        updated_at as updated_timestamp,
        url,
        workspace

        {{ fivetran_utils.fill_pass_through_columns('marketo__program_passthrough_columns') }}

    from macro
    where not coalesce(_fivetran_deleted, false)
    
)

select *
from fields
