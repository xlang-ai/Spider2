with base as (

    select * 
    from {{ ref('stg_intercom__conversation_history_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_intercom__conversation_history_tmp')),
                staging_columns=get_conversation_history_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as conversation_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        assignee_id,
        assignee_type,
        conversation_rating_value,
        conversation_rating_remark,
        cast(first_contact_reply_created_at as {{ dbt.type_timestamp() }}) as first_contact_reply_created_at,
        first_contact_reply_type,
        read as is_read,
        source_author_id,
        source_author_type,
        source_delivered_as,
        source_type,
        source_subject,
        state,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        cast(waiting_since as {{ dbt.type_timestamp() }}) as waiting_since,
        cast(snoozed_until as {{ dbt.type_timestamp() }}) as snoozed_until,
        sla_name,
        sla_status,
        _fivetran_active,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end

        --The below script allows for pass through columns.
        {{ fivetran_utils.fill_pass_through_columns('intercom__conversation_history_pass_through_columns') }}
    from fields
)

select * 
from final