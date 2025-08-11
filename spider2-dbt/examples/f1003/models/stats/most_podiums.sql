with finishes_by_driver as (
  select *
    from {{ ref('finishes_by_driver') }}
),
final as (
  select rank() over (order by podiums desc) as rank,
         driver_full_name,
         podiums,
         p1,
         p2,
         p3
    from finishes_by_driver
   order by podiums desc
   limit 20
)

select *
  from final