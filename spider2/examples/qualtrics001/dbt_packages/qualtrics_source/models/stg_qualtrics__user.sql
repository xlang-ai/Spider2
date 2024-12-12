
with base as (

    select * 
    from {{ ref('stg_qualtrics__user_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__user_tmp')),
                staging_columns=get_user_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='qualtrics_union_schemas', 
            union_database_variable='qualtrics_union_databases') 
        }}
            
    from base
),

final as (
    
    select 
        cast(account_creation_date as {{ dbt.type_timestamp() }}) as account_created_at,
        cast(account_expiration_date as {{ dbt.type_timestamp() }}) as account_expires_at,
        account_status,
        division_id,
        email,
        first_name,
        id as user_id,
        language,
        cast(last_login_date as {{ dbt.type_timestamp() }}) as last_login_at,
        last_name,
        organization_id,
        cast(password_expiration_date as {{ dbt.type_timestamp() }}) as password_expires_at,
        cast(password_last_changed_date as {{ dbt.type_timestamp() }}) as password_last_changed_at,
        response_count_auditable,
        response_count_deleted,
        response_count_generated,
        time_zone,
        unsubscribed as is_unsubscribed,
        user_type,
        username,
        _fivetran_deleted as is_deleted,
        _fivetran_synced,
        source_relation
    from fields
)

select *
from final
