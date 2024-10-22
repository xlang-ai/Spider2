--To disable this model, set the intercom__using_contact_company variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_contact_company', True)) }}

with base as (

    select * 
    from {{ ref('stg_intercom__company_history_tmp') }}

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
                source_columns=adapter.get_columns_in_relation(ref('stg_intercom__company_history_tmp')),
                staging_columns=get_company_history_columns()
            )
        }}

    from base
),

final as (
    
    select 
        id as company_id,
        name as company_name,
        website,
        industry,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        user_count,
        session_count,
        monthly_spend,
        plan_id,
        plan_name,
        _fivetran_active,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end

        --The below script allows for pass through columns.
        {{ fivetran_utils.fill_pass_through_columns('intercom__company_history_pass_through_columns') }}
    from fields
)

select * 
from final
where coalesce(_fivetran_active, true)
