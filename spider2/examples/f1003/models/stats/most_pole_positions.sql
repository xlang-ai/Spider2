with finishes_by_driver as (
  select *
    from {{ ref('finishes_by_driver') }}
),
final as (
  select rank() over (order by pole_positions desc) as rank,
         driver_full_name,
         pole_positions
    from finishes_by_driver
   order by pole_positions desc
   limit 20
)

select *
  from final