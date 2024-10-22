with base as (

    select * 
    from {{ ref('stg_twilio__incoming_phone_number_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twilio__incoming_phone_number_tmp')),
                staging_columns=get_incoming_phone_number_columns()
            )
        }}
    from base
),

final as (
    
    select 
        _fivetran_synced,
        account_id,
        cast(address_id as {{ dbt.type_string() }}) as address_id, 
        capabilities_mms,
        capabilities_sms,
        capabilities_voice,
        created_at,
        emergency_address_id,
        emergency_status,
        friendly_name,
        id as incoming_phone_number_id,
        origin,
        phone_number,
        trunk_id,
        updated_at,
        voice_caller_id_lookup,
        voice_url
    from fields
)

select *
from final
