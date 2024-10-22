--To disable this model, set the using_twilio_call variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_twilio_call', True)) }}

with base as (

    select * 
    from {{ ref('stg_twilio__call_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_twilio__call_tmp')),
                staging_columns=get_call_columns()
            )
        }}
    from base
),

final as (
    
    select 
        _fivetran_synced,
        account_id,
        annotation,
        answered_by,
        caller_name,
        created_at,
        direction,
        cast( {{ twilio_source.remove_non_numeric_chars('duration')}} as {{ dbt.type_float() }}) as duration,
        end_time,
        forwarded_from,
        call_from, -- renamed in the get_call_columns macro
        from_formatted,
        group_id,
        id as call_id,
        outgoing_caller_id,
        parent_call_id,
        cast( {{ twilio_source.remove_non_numeric_chars('price')}} as {{ dbt.type_float() }}) as price,
        price_unit,
        cast( {{ twilio_source.remove_non_numeric_chars('queue_time')}} as {{ dbt.type_float() }}) as queue_time,
        start_time,
        status,
        call_to, -- renamed in the get_call_columns macro
        to_formatted,
        trunk_id,
        updated_at
    from fields
)

select *
from final
