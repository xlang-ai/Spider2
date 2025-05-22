{{ config(enabled=var('apple_store__using_subscriptions', False)) }}

with base as (

    select * 
    from {{ ref('stg_apple_store__sales_subscription_summary_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_apple_store__sales_subscription_summary_tmp')),
                staging_columns=get_sales_subscription_summary_columns()
            )
        }}
        
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='apple_store_union_schemas', 
            union_database_variable='apple_store_union_databases') 
        }}

    from base
),

final as (

    select
        cast(source_relation as {{ dbt.type_string() }}) as source_relation, 
        cast({{ get_date_from_string( dbt.split_part(string_text='_filename', delimiter_text="'_'", part_number=3)) }} as date) as date_day, 
        cast(app_name as {{ dbt.type_string() }}) as app_name,
        cast(account_number as {{ dbt.type_bigint() }}) as account_id,
        cast(country as {{ dbt.type_string() }}) as country,
        cast(case
            when replace(state, ' ', '') = '' then cast(null as {{ dbt.type_string() }}) else state
        end as {{ dbt.type_string() }}) as state,
        cast(subscription_name as {{ dbt.type_string() }}) as subscription_name,
        cast(case 
            when lower(device) like 'ipod%' then 'iPod' else device
        end as {{ dbt.type_string() }}) as device,
        sum(cast(active_free_trial_introductory_offer_subscriptions as {{ dbt.type_bigint() }})) as active_free_trial_introductory_offer_subscriptions,
        sum(cast(active_pay_as_you_go_introductory_offer_subscriptions as {{ dbt.type_bigint() }})) as active_pay_as_you_go_introductory_offer_subscriptions,
        sum(cast(active_pay_up_front_introductory_offer_subscriptions as {{ dbt.type_bigint() }})) as active_pay_up_front_introductory_offer_subscriptions,
        sum(cast(active_standard_price_subscriptions as {{ dbt.type_bigint() }})) as active_standard_price_subscriptions
    from fields
    {{ dbt_utils.group_by(8) }}
)

select * 
from final