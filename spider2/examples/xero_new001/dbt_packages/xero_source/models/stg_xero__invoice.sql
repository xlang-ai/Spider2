
with base as (

    select * 
    from {{ ref('stg_xero__invoice_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_xero__invoice_tmp')),
                staging_columns=get_invoice_columns()
            )
        }}
        
        {{ fivetran_utils.add_dbt_source_relation() }}
    from base
),

final as (
    
    select 
        -- IDs
        invoice_id,
        contact_id,

        -- dates
        date as invoice_date,
        updated_date_utc as updated_date,
        planned_payment_date,
        due_date,
        expected_payment_date,
        fully_paid_on_date,
        _fivetran_synced,

        currency_code,
        currency_rate,
        invoice_number,
        reference,
        sent_to_contact as is_sent_to_contact,
        status as invoice_status,
        type,
        url

        {{ fivetran_utils.source_relation() }}
        
    from fields
)

select * from final
