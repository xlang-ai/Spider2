with base as (

    select * 
    from {{ ref('stg_twilio__address_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twilio__address_tmp')),
                staging_columns=get_address_columns()
            )
        }}
    from base
),

final as (
    
    select 
        _fivetran_synced,
        account_id,
        city,
        created_at,
        customer_name,
        emergency_enabled,
        friendly_name,
        cast(id as {{ dbt.type_string() }}) as address_id,
        iso_country,
        postal_code,
        region,
        street,
        updated_at,
        validated,
        verified
    from fields
)

select *
from final
