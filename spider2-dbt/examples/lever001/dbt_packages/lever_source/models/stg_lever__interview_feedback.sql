
with base as (

    select * 
    from {{ ref('stg_lever__interview_feedback_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_lever__interview_feedback_tmp')),
                staging_columns=get_interview_feedback_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        interview_id, 
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        feedback_form_id
    from fields
)

select * 
from final
