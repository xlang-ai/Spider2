
with base as (

    select * 
    from {{ ref('stg_asana__team_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__team_tmp')),
                staging_columns=get_team_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        id as team_id,
        name as team_name
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
