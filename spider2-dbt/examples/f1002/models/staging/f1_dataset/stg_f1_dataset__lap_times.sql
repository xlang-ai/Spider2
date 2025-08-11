with lap_times as (
  select raceId as race_id,
         driverId as driver_id,
         lap,
         position,
         time,
         milliseconds
    from {{ ref('lap_times') }}
)

select *
  from lap_times