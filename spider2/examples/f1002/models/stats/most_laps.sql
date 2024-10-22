with drivers as (
  select *
    from {{ ref('stg_f1_dataset__drivers') }}
),
lap_times as (
  select *
    from {{ ref('stg_f1_dataset__lap_times') }}
),
joined as (
  select d.driver_id,
         d.driver_full_name
    from drivers as d
    join lap_times as l
   using (driver_id)
),
grouped as (
  select driver_id,
         driver_full_name,
         count(*) as laps
    from joined
   group by 1, 2
),
final as (
  select rank() over (order by laps desc) as rank,
         driver_full_name,
         laps
    from grouped
   order by laps desc
   limit 20
)

select *
  from final