{{ config(enabled=var('greenhouse_using_job_office', True)) }}

with base as (

    select * 
    from {{ ref('stg_greenhouse__office_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__office_tmp')),
                staging_columns=get_office_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        external_id as external_office_id,
        id as office_id,
        location_name,
        name as office_name,
        parent_id as parent_office_id,
        primary_contact_user_id
        
    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
