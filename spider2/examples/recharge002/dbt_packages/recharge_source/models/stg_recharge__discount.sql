
with base as (

    select *
    from {{ ref('stg_recharge__discount_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__discount_tmp')),
                staging_columns = get_discount_columns()
            )
        }}
    from base
),

final as (

    select
        id as discount_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as discount_created_at,
        cast(updated_at as {{ dbt.type_timestamp() }}) as discount_updated_at,
        cast(starts_at as {{ dbt.type_timestamp() }}) as discount_starts_at,
        cast(ends_at as {{ dbt.type_timestamp() }}) as discount_ends_at,
        code,
        value,
        status,
        usage_limits,
        applies_to,
        applies_to_resource,
        applies_to_id,
        applies_to_product_type,
        minimum_order_amount
    from fields
)

select *
from final