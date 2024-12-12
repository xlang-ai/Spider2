
with base as (

    select *
    from {{ ref('stg_recharge__address_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__address_tmp')),
                staging_columns = get_address_columns()
            )
        }}
    from base
),

final as (

    select
        id as address_id,
        customer_id,
        first_name,
        last_name,
        cast(created_at as {{ dbt.type_timestamp() }}) as address_created_at,
        cast(updated_at as {{ dbt.type_timestamp() }}) as address_updated_at,
        address_1 as address_line_1,
        address_2 as address_line_2,
        city,
        province,
        zip,
        country_code,
        country,
        company,
        phone,
        payment_method_id

        {{ fivetran_utils.fill_pass_through_columns('recharge__address_passthrough_columns') }}

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final