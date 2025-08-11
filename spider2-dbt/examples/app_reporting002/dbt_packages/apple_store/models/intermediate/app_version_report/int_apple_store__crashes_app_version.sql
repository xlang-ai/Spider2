with base as (

    select *
    from {{ var('crashes_app_version') }}
),

aggregated as (

    select 
        source_relation,
        date_day, 
        app_id,
        app_version,
        cast(null as {{ dbt.type_string() }}) as source_type,
        sum(crashes) as crashes
    from base
    {{ dbt_utils.group_by(5) }}
)

select * 
from aggregated