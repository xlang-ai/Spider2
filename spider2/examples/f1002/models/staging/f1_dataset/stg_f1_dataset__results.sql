with results as (
  select statusId as status_id,
          raceId as race_id,
          driverId as driver_id,
          constructorId as constructor_id,
          resultId as result_id,
          grid,
          positionOrder as position_order,
          points,
          laps,
          fastestLapTime as fastest_lap_time,
          fastestLapSpeed as fastest_lap_speed,
          time as lap_time,
          milliseconds as lap_milliseconds,
          number as lap_number,
          fastestLap as fastest_lap,
          position,
          positionText as position_text,
          rank

    from {{ ref('results') }}
),

status_descriptions as (
  select statusId as status_id,
         status as status_desc
    from {{ ref('status') }}
),

position_descriptions as (
  select *
    from {{ ref('position_descriptions') }}
),

final as (
  select r.status_id,
         r.race_id,
         r.driver_id,
         r.constructor_id,
         r.result_id,
         r.grid,
         r.position_order,
         r.points,
         r.laps,
         r.fastest_lap_time,
         r.fastest_lap_speed,
         r.lap_time,
         r.lap_milliseconds,
         r.lap_number,
         r.fastest_lap,
         r.position,
         r.rank,
         s.status_desc,
         p.position_desc
    from results as r
    left join position_descriptions as p
  using (position_text)
    left join status_descriptions as s
  using (status_id)
)

select *
  from final