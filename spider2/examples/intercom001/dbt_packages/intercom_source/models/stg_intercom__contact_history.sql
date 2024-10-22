with base as (

    select * 
    from {{ ref('stg_intercom__contact_history_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_intercom__contact_history_tmp')),
                staging_columns=get_contact_history_columns()
            )
        }}

    from base
),

final as (
    
    select 
        id as contact_id,
        admin_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        cast(signed_up_at as {{ dbt.type_timestamp() }}) as signed_up_at,
        name as contact_name, 
        role as contact_role,
        email as contact_email,
        cast(last_replied_at as {{ dbt.type_timestamp() }}) as last_replied_at,
        cast(last_email_clicked_at as {{ dbt.type_timestamp() }}) as last_email_clicked_at,
        cast(last_email_opened_at as {{ dbt.type_timestamp() }}) as last_email_opened_at,
        cast(last_contacted_at as {{ dbt.type_timestamp() }}) as last_contacted_at,
        unsubscribed_from_emails as is_unsubscribed_from_emails,
        _fivetran_active,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end

        --The below script allows for pass through columns.
        {{ fivetran_utils.fill_pass_through_columns('intercom__contact_history_pass_through_columns') }}
    from fields
)

select * 
from final
