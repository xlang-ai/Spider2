with base as (

    select *
    from {{ var('crashes_app_version') }}
),

aggregated as (

    select 
        source_relation,
        date_day, 
        app_id,
        sum(crashes) as crashes
    from base
    {{ dbt_utils.group_by(3) }}
)

select * 
from aggregated