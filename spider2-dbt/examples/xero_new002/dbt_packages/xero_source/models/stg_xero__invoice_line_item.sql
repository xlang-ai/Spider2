
with base as (

    select * 
    from {{ ref('stg_xero__invoice_line_item_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_xero__invoice_line_item_tmp')),
                staging_columns=get_invoice_line_item_columns()
            )
        }}

        {{ fivetran_utils.add_dbt_source_relation() }}    
    from base
),

final as (
    
    select 
        _fivetran_synced,
        account_code,
        description as line_item_description,
        discount_entered_as_percent,
        discount_rate,
        invoice_id,
        item_code,
        line_amount,
        line_item_id,
        quantity,
        tax_amount,
        tax_type,
        unit_amount

        {{ fivetran_utils.source_relation() }}
        
    from fields
)

select * from final
