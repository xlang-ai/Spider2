
with base as (

    select * 
    from {{ ref('stg_xero__journal_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_xero__journal_tmp')),
                staging_columns=get_journal_columns()
            )
        }}

        {{ fivetran_utils.add_dbt_source_relation() }}
    from base
),

final as (
    
    select 
        journal_id,
        created_date_utc,
        journal_date,
        journal_number,
        reference,
        source_id,
        source_type

        {{ fivetran_utils.source_relation() }}
        
    from fields
)

select * from final
