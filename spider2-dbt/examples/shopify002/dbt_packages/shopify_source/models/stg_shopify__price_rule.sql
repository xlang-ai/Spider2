
with base as (

    select * 
    from {{ ref('stg_shopify__price_rule_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__price_rule_tmp')),
                staging_columns=get_price_rule_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='shopify_union_schemas', 
            union_database_variable='shopify_union_databases') 
        }}

    from base
),

final as (
    
    select
        id as price_rule_id,
        allocation_limit,
        allocation_method,
        customer_selection,
        once_per_customer as is_once_per_customer,
        prerequisite_quantity_range as prereq_min_quantity,
        prerequisite_shipping_price_range as prereq_max_shipping_price,
        prerequisite_subtotal_range as prereq_min_subtotal,
        prerequisite_to_entitlement_purchase_prerequisite_amount as prereq_min_purchase_quantity_for_entitlement,
        quantity_ratio_entitled_quantity as prereq_buy_x_get_this,
        quantity_ratio_prerequisite_quantity as prereq_buy_this_get_y,
        target_selection,
        target_type,
        title,
        usage_limit,
        value,
        value_type,
        {{ dbt_date.convert_timezone(column='cast(starts_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as starts_at,
        {{ dbt_date.convert_timezone(column='cast(ends_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as ends_at,
        {{ dbt_date.convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_at,
        {{ dbt_date.convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ dbt_date.convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

    from fields
)

select *
from final
