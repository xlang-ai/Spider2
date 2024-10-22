
with base as (

    select * 
    from {{ ref('stg_xero__journal_line_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_xero__journal_line_tmp')),
                staging_columns=get_journal_line_columns()
            )
        }}

        {{ fivetran_utils.add_dbt_source_relation() }}
    from base
),

final as (
    
    select 
        journal_line_id,
        account_code,
        account_id,
        account_name,
        account_type,
        description,
        gross_amount,
        journal_id,
        net_amount,
        tax_amount,
        tax_name,
        tax_type

        {{ fivetran_utils.source_relation() }}
        
    from fields
)

select * from final
