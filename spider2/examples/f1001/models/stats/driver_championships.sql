with
    driver_points as (
        select
            drivers.driver_full_name,
            max(driver_standings.points) as max_points,
            races.race_year as race_year
        from {{ ref("stg_f1_dataset__drivers") }} drivers
        join
            {{ ref("stg_f1_dataset__results") }} results
            on drivers.driver_id = results.driver_id
        join {{ ref("stg_f1_dataset__races") }} races on results.race_id = races.race_id
        join
            {{ ref("stg_f1_dataset__driver_standings") }} driver_standings
            on driver_standings.raceid = races.race_id
            and driver_standings.driverid = results.driver_id
        group by drivers.driver_full_name, races.race_year
    ),
    driver_championships as (
        select
            *, rank() over (partition by race_year order by max_points desc) as r_rank
        from driver_points
        where race_year != EXTRACT(YEAR FROM CURRENT_DATE())
    )

select driver_full_name, count(driver_full_name) as total_championships
from driver_championships
where r_rank = 1
group by driver_full_name
