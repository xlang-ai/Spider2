with drivers as (
  select *
    from {{ ref('stg_f1_dataset__drivers') }}
),
results as (
  select *
    from {{ ref('stg_f1_dataset__results') }}
),
joined as (
  select d.driver_id,
         d.driver_full_name,
         r.position_desc
    from results as r
    join drivers as d
   using (driver_id)
),
grouped as (
  select driver_id,
         driver_full_name,
         sum(case
               when position_desc is null
               then 1
               else 0
             end) as finishes,
         {{
           dbt_utils.pivot(
             'position_desc',
             dbt_utils.get_column_values(
               ref('position_descriptions'),
               'position_desc'
             )
           )
         }}
    from joined
   group by 1, 2
),
final as (
  select rank() over (order by finishes desc) as rank,
         driver_full_name,
         finishes,
         excluded,
         withdrew,
         "failed to qualify" as failed_to_qualify,
         disqualified,
         "not classified" as not_classified,
         retired
    from grouped
   order by finishes desc
   limit 120
)

select *
  from final