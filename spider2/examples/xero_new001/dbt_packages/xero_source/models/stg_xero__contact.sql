
with base as (

    select * 
    from {{ ref('stg_xero__contact_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_xero__contact_tmp')),
                staging_columns=get_contact_columns()
            )
        }}

        {{ fivetran_utils.add_dbt_source_relation() }}        
    from base
),

final as (
    
    select 
        contact_id,
        name as contact_name

        {{ fivetran_utils.source_relation() }}
        
    from fields
    where _fivetran_deleted = False
)

select * from final
