with races as (
  select date as race_date,
         round as round_number,
         raceId as race_id,
         circuitId as circuit_id,
         year as race_year,
         time as race_time,
         url as race_url,
         name as race_name

    from {{ ref('races') }}
),

circuits as (
  select *
    from {{ ref('stg_f1_dataset__circuits') }}
),

final as (
  select r.race_date,
         r.round_number,
         r.race_id,
         r.race_year,
         r.race_time,
         r.race_url,
         r.race_name,
         circuit_id,
         c.circuit_name,
         c.latitude,
         c.longitude,
         c.alitude,
         c.country,
         c.circuit_url,
         c.circuit_ref,
         c.circuit_location,
         r.race_date >= '1983-01-01' as is_modern_era
    from races as r
    join circuits as c
   using (circuit_id)
)

select *
  from final