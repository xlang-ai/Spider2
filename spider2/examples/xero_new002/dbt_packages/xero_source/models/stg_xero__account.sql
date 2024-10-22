
with base as (

    select * 
    from {{ ref('stg_xero__account_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_xero__account_tmp')),
                staging_columns=get_account_columns()
            )
        }}

        {{ fivetran_utils.add_dbt_source_relation() }}
    from base
),

final as (
    
    select 
        account_id,
        name as account_name,
        code as account_code,
        type as account_type,
        class as account_class,
        _fivetran_synced

        {{ fivetran_utils.source_relation() }}

    from fields

)

select * from final
