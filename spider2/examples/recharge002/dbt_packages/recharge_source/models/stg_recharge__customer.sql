
with base as (

    select *
    from {{ ref('stg_recharge__customer_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__customer_tmp')),
                staging_columns = get_customer_columns()
            )
        }}
    from base
),

final as (

    select
        id as customer_id,
        customer_hash,
        external_customer_id_ecommerce,
        email,
        first_name,
        last_name,
        cast(created_at as {{ dbt.type_timestamp() }}) as customer_created_at,
        cast(updated_at as {{ dbt.type_timestamp() }}) as customer_updated_at,
        cast(first_charge_processed_at as {{ dbt.type_timestamp() }}) as first_charge_processed_at,
        subscriptions_active_count,
        subscriptions_total_count,
        has_valid_payment_method,
        has_payment_method_in_dunning,
        tax_exempt,
        billing_first_name,
        billing_last_name,
        billing_company,
        billing_city,
        billing_country
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final