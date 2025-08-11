with usage_data as (
    select
        usage,
        injection,
        validated
    from {{ ref('fct_electricity') }}
),

final as (
    select
        sum(usage) as usage,
        sum(injection) as injection,
        validated
    from usage_data
    group by validated
)

select *
from final