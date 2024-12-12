
with base as (

    select * 
    from {{ ref('stg_pendo__user_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_pendo__user_tmp')),
                staging_columns=get_user_columns()
            )
        }}
        
    from base
),

final as (
    
    select 

        id as user_id,
        deleted_at,
        first_name,
        last_name,
        user_type,
        username,
        _fivetran_synced

    from fields
)

select * 
from final
