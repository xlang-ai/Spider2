
with base as (

    select * 
    from {{ ref('stg_lever__application_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__application_tmp')),
                staging_columns=get_application_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as application_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(archived_at as {{ dbt.type_timestamp() }}) as archived_at,
        archived_reason_id,
        comments,
        company,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        opportunity_id,
        posting_hiring_manager_id as posting_hiring_manager_user_id,
        posting_id,
        posting_owner_id as posting_owner_user_id,
        referrer_id as referrer_user_id,
        requisition_for_hire_id as requisition_id,
        type
    from fields
)

select * 
from final
