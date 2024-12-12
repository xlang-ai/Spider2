with finishes_by_driver as (
  select *
    from {{ ref('finishes_by_driver') }}
),
final as (
  select rank() over (order by p1 desc) as rank,
         driver_full_name,
         p1 as wins
    from finishes_by_driver
   order by p1 desc
   limit 20
)

select *
  from final