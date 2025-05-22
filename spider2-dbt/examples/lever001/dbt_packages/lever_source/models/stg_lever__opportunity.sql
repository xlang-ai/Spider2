
with base as (

    select * 
    from {{ ref('stg_lever__opportunity_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__opportunity_tmp')),
                staging_columns=get_opportunity_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(archived_at as {{ dbt.type_timestamp() }}) as archived_at,
        archived_reason_id,
        contact as contact_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        data_protection_contact_allowed as is_data_protection_contact_allowed, 
        cast(data_protection_contact_expires_at as {{ dbt.type_timestamp() }}) as data_protection_contact_expires_at,
        data_protection_store_allowed as is_data_protection_store_allowed,
        cast(data_protection_store_expires_at as {{ dbt.type_timestamp() }}) as data_protection_store_expires_at,
        headline as contact_headline,
        id as opportunity_id, 
        is_anonymized,
        cast(last_advanced_at as {{ dbt.type_timestamp() }}) as last_advanced_at,
        cast(last_interaction_at as {{ dbt.type_timestamp() }}) as last_interaction_at,
        location as contact_location,
        name as contact_name,
        origin,
        owner_id as owner_user_id,
        snoozed_until,
        stage_id,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at
    from fields
)

select * 
from final