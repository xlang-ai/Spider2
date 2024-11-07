with base as (

    select * 
    from {{ ref('stg_lever__contact_email_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__contact_email_tmp')),
                staging_columns=get_contact_email_columns()
            )
        }}
        
    from base
),

final as (

    select 
        contact_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        email
    from fields
)

select *
from final
