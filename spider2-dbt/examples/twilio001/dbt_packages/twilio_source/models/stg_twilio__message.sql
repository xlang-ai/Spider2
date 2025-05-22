with base as (

    select * 
    from {{ ref('stg_twilio__message_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twilio__message_tmp')),
                staging_columns=get_message_columns()
            )
        }}
    from base
),

final as (
    
    select 
        _fivetran_synced,
        account_id,
        body,
        created_at,
        cast(date_sent as {{ dbt.type_timestamp() }}) as timestamp_sent,
        direction,
        error_code,
        error_message,
        message_from, -- renamed in the get_message_columns macro
        id as message_id,
        cast(messaging_service_sid as {{ dbt.type_string() }}) as messaging_service_id,
        cast( {{ twilio_source.remove_non_numeric_chars('num_media')}} as {{ dbt.type_float() }}) as num_media,
        cast( {{ twilio_source.remove_non_numeric_chars('num_segments')}} as {{ dbt.type_float() }}) as num_segments,
        cast( {{ twilio_source.remove_non_numeric_chars('price')}} as {{ dbt.type_float() }}) as price,
        price_unit,
        status,
        message_to, -- renamed in the get_message_columns macro
        updated_at
    from fields
)

select *
from final
