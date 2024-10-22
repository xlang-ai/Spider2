
with base as (

    select *
    from {{ ref('stg_recharge__charge_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__charge_tmp')),
                staging_columns = get_charge_columns()
            )
        }}
    from base
),

final as (

    select
        id as charge_id,
        customer_id,
        customer_hash,
        email,
        cast(created_at as {{ dbt.type_timestamp() }}) as charge_created_at,
        type as charge_type,
        status as charge_status,
        cast(updated_at as {{ dbt.type_timestamp() }}) as charge_updated_at,
        note,
        subtotal_price,
        tax_lines,
        total_discounts,
        total_line_items_price,
        total_tax,
        cast(total_price as {{ dbt.type_float() }}) as total_price,
        total_refunds,
        total_weight_grams,
        cast(scheduled_at as {{ dbt.type_timestamp() }}) as charge_scheduled_at,
        cast(processed_at as {{ dbt.type_timestamp() }}) as charge_processed_at,
        payment_processor,
        external_transaction_id_payment_processor,
        external_order_id_ecommerce,
        orders_count,
        has_uncommitted_changes,
        cast(retry_date as {{ dbt.type_timestamp() }}) as retry_date,
        error_type,
        charge_attempts as times_retried,
        address_id,
        client_details_browser_ip,
        client_details_user_agent,
        tags,
        error,
        external_variant_id_not_found

        {{ fivetran_utils.fill_pass_through_columns('recharge__charge_passthrough_columns') }}

    from fields
)

select *
from final