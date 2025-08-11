
with base as (

    select * 
    from {{ ref('stg_qualtrics__contact_mailing_list_membership_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_qualtrics__contact_mailing_list_membership_tmp')),
                staging_columns=get_contact_mailing_list_membership_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='qualtrics_union_schemas', 
            union_database_variable='qualtrics_union_databases') 
        }}
        
    from base
),

final as (
    
    select 
        contact_id,
        contact_lookup_id,
        directory_id,
        mailing_list_id,
        name,
        owner_id as owner_user_id,
        cast(unsubscribe_date as {{ dbt.type_timestamp() }}) as unsubscribed_at,
        unsubscribed as is_unsubscribed,
        _fivetran_synced,
        source_relation

    from fields
)

select *
from final
