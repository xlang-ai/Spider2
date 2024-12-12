with races as (
  select *
    from {{ ref('stg_f1_dataset__races') }}
),
results as (
  select *
    from {{ ref('stg_f1_dataset__results') }}
),
drivers as (
  select *
    from {{ ref('stg_f1_dataset__drivers') }}
),
joined as (
  select *
    from results
    join races
   using (race_id)
    join drivers
   using (driver_id)
),
wins as (
  select driver_full_name,
         race_name,
         race_date,
         EXTRACT(YEAR FROM race_date) - EXTRACT(YEAR FROM driver_date_of_birth) as age,
         is_modern_era
    from joined
   where position_order = 1
),
final as (
  select driver_full_name,
         race_name,
         race_date,
         age
    from wins
   where is_modern_era
   order by age desc
   limit 20
)

select *
  from final