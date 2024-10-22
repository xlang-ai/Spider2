with finishes_by_driver as (
  select *
    from {{ ref('finishes_by_driver') }}
),
final as (
  select rank() over (order by retired desc) as rank,
         driver_full_name,
         retired as retirements
    from finishes_by_driver
   order by retired desc
   limit 20
)

select *
  from final