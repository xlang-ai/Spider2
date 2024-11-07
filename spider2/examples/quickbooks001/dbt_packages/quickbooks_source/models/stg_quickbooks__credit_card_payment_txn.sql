--To enable this model, set the using_invoice_bundle variable within your dbt_project.yml file to True.
{{ config(enabled=var('using_credit_card_payment_txn', False)) }}

with base as (

    select * 
    from {{ ref('stg_quickbooks__credit_card_payment_txn_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_quickbooks__credit_card_payment_txn_tmp')),
                staging_columns=get_credit_card_payment_txn_columns()
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
        cast(id as {{ dbt.type_string() }}) as credit_card_payment_id,
        amount,
        bank_account_id,
        credit_card_account_id,
        created_at,
        updated_at,
        currency_id,
        cast( {{ dbt.date_trunc('day', 'transaction_date') }} as date) as transaction_date,
        _fivetran_deleted,
        row_number() over (partition by id, updated_at, source_relation order by source_relation, updated_at desc) = 1 as is_most_recent_record,
        source_relation
    from fields
)

select * 
from final
where not coalesce(_fivetran_deleted, false)