with base as (

    select * 
    from {{ ref('stg_intercom__conversation_contact_history_tmp') }}

),

fields as (

    select
    /*
    The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
    that are expected/needed (staging_columns from dbt_intercom_source/models/tmp/) and compares it with columns 
    in the source (source_columns from dbt_intercom_source/macros/).
    For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
    */
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_intercom__conversation_contact_history_tmp')),
                staging_columns=get_conversation_contact_history_columns()
            )
        }}
    from base
),

final as (
    
    select 
        contact_id,
        conversation_id,
        cast(conversation_updated_at as {{ dbt.type_timestamp() }}) as conversation_updated_at,
        _fivetran_active,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end
    from fields
)

select * 
from final
