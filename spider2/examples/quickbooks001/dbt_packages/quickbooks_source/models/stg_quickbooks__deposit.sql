--To disable this model, set the using_deposit variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_deposit', True)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__deposit_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_quickbooks_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_quickbooks_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__deposit_tmp')),
                staging_columns=get_deposit_columns()
            )
        }}

        {{ 
            fivetran_utils.source_relation(
                union_schema_variable='quickbooks_union_schemas', 
                union_database_variable='quickbooks_union_databases'
                ) 
        }}
        
    from base
),

final as (
    
    select 
        cast(id as {{ dbt.type_string() }}) as deposit_id,
        cast(account_id as {{ dbt.type_string() }}) as account_id,
        created_at,
        currency_id,
        cast(department_id as {{ dbt.type_string() }}) as department_id,
        total_amount,
        home_total_amount,
        cast( {{ dbt.date_trunc('day', 'transaction_date') }} as date) as transaction_date,
        transaction_status,
        _fivetran_deleted,
        source_relation
    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)
