with finishes_by_driver as (
  select *
    from {{ ref('finishes_by_driver') }}
),
final as (
  select rank() over (order by fastest_laps desc) as rank,
         driver_full_name,
         fastest_laps
    from finishes_by_driver
   order by fastest_laps desc
   limit 20
)

select *
  from final