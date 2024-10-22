
with base as (

    select *
    from {{ ref('stg_recharge__charge_discount_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__charge_discount_tmp')),
                staging_columns = get_charge_discount_columns()
            )
        }}
    from base
),

final as (

    select
        charge_id,
        index,
        id as discount_id, 
        code,
        cast(value as {{ dbt.type_float() }}) as discount_value,
        value_type
    from fields
)

select *
from final