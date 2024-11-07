with drivers as (
  select *
    from {{ ref('stg_f1_dataset__drivers') }}
),
results as (
  select *
    from {{ ref('stg_f1_dataset__results') }}
),
qualifying as (
    select * 
       from {{ ref("stg_f1_dataset__qualifying") }}
),
podiums as (
  select d.driver_id,
         d.driver_full_name,
         r.position_order,
         r.position_desc,
         r.grid as grid_position_order,
         r.rank as fastest_lap
    from results as r
    join drivers as d using (driver_id)
),
grouped as (
  select driver_id,
         driver_full_name,
         count(*) as races,
         count_if(position_order between 1 and 3) as podiums,
         count_if(grid_position_order = 1) as pole_positions,
         count_if(fastest_lap = 1) as fastest_laps,
         sum(case when position_order = 1 then 1 else 0 end) as p1,
            sum(case when position_order = 2 then 1 else 0 end) as p2,
            sum(case when position_order = 3 then 1 else 0 end) as p3,
            sum(case when position_order = 4 then 1 else 0 end) as p4,
            sum(case when position_order = 5 then 1 else 0 end) as p5,
            sum(case when position_order = 6 then 1 else 0 end) as p6,
            sum(case when position_order = 7 then 1 else 0 end) as p7,
            sum(case when position_order = 8 then 1 else 0 end) as p8,
            sum(case when position_order = 9 then 1 else 0 end) as p9,
            sum(case when position_order = 10 then 1 else 0 end) as p10,
            sum(case when position_order = 11 then 1 else 0 end) as p11,
            sum(case when position_order = 12 then 1 else 0 end) as p12,
            sum(case when position_order = 13 then 1 else 0 end) as p13,
            sum(case when position_order = 14 then 1 else 0 end) as p14,
            sum(case when position_order = 15 then 1 else 0 end) as p15,
            sum(case when position_order = 16 then 1 else 0 end) as p16,
            sum(case when position_order = 17 then 1 else 0 end) as p17,
            sum(case when position_order = 18 then 1 else 0 end) as p18,
            sum(case when position_order = 19 then 1 else 0 end) as p19,
            sum(case when position_order = 20 then 1 else 0 end) as p20,
            sum(case when position_order > 20 then 1 else 0 end) as p21plus,
            sum(
                case when position_desc = 'disqualified' then 1 else 0 end
            ) as disqualified,
            sum(case when position_desc = 'excluded' then 1 else 0 end) as excluded,
            sum(
                case when position_desc = 'failed to qualify' then 1 else 0 end
            ) as failed_to_qualify,
            sum(
                case when position_desc = 'not classified' then 1 else 0 end
            ) as not_classified,
            sum(case when position_desc = 'retired' then 1 else 0 end) as retired,
            sum(case when position_desc = 'withdrew' then 1 else 0 end) as withdrew
        from podiums 
        group by 1, 2
),
final as (
  select *
    from grouped
)

select *
  from final