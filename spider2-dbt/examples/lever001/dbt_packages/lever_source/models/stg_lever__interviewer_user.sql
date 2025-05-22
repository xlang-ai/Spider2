
with base as (

    select * 
    from {{ ref('stg_lever__interviewer_user_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__interviewer_user_tmp')),
                staging_columns=get_interviewer_user_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        interview_id,
        user_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from fields
)

select * 
from final
