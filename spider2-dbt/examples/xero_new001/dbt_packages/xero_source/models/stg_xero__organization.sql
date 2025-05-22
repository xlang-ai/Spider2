
with base as (

    select * 
    from {{ ref('stg_xero__organization_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_xero__organization_tmp')),
                staging_columns=get_organization_columns()
            )
        }}

        {{ fivetran_utils.add_dbt_source_relation() }}
    from base
),

final as (
    
    select 
        organisation_id,
        financial_year_end_month,
        financial_year_end_day

        {{ fivetran_utils.source_relation() }}
        
    from fields
)

select * from final
