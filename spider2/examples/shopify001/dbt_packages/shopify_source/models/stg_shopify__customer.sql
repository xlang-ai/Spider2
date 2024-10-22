with base as (

    select * 
    from {{ ref('stg_shopify__customer_tmp') }}

),

fields as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__customer_tmp')),
                staging_columns=get_customer_columns()
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
        id as customer_id,
        lower(email) as email,
        first_name,
        last_name,
        orders_count,
        default_address_id,
        phone,
        lower(state) as account_state,
        tax_exempt as is_tax_exempt,
        total_spent,
        verified_email as is_verified_email,
        note,
        currency,
        case 
            when email_marketing_consent_state is null then
                case 
                    when accepts_marketing is null then null
                    when accepts_marketing then 'subscribed (legacy)' 
                    else 'not_subscribed (legacy)' end
            else lower(email_marketing_consent_state) end as marketing_consent_state,
        lower(coalesce(email_marketing_consent_opt_in_level, marketing_opt_in_level)) as marketing_opt_in_level,

        {{ dbt_date.convert_timezone(column='cast(coalesce(accepts_marketing_updated_at, email_marketing_consent_consent_updated_at) as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as marketing_consent_updated_at,
        {{ dbt_date.convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_timestamp,
        {{ dbt_date.convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_timestamp,
        {{ dbt_date.convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation
        
        {{ fivetran_utils.fill_pass_through_columns('customer_pass_through_columns') }}

    from fields
    
)

select * 
from final