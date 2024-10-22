with base as (

    select * 
    from {{ ref('stg_twilio__outgoing_caller_id_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twilio__outgoing_caller_id_tmp')),
                staging_columns=get_outgoing_caller_id_columns()
            )
        }}
    from base
),

final as (
    
    select 
        _fivetran_synced,
        created_at,
        friendly_name,
        id as outgoing_caller_id,
        phone_number,
        updated_at
    from fields
)

select *
from final
