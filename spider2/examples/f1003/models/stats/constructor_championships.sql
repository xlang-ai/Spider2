with
    constructor_points as (
        select
            constructors.constructor_name,
            max(constructor_standings.points) as max_points,
            races.race_year as race_year
        from {{ ref("stg_f1_dataset__constructors") }} constructors
        join
            {{ ref("stg_f1_dataset__results") }} results
            on constructors.constructor_id = results.constructor_id
        join {{ ref("stg_f1_dataset__races") }} races on results.race_id = races.race_id
        join
            {{ ref("stg_f1_dataset__constructor_standings") }} constructor_standings
            on constructor_standings.raceid = races.race_id
            and constructor_standings.constructorid = results.constructor_id
        group by constructors.constructor_name, races.race_year
    ),
    constructor_championships as (
        select
            *, rank() over (partition by race_year order by max_points desc) as r_rank
        from constructor_points
        where race_year != EXTRACT(YEAR FROM CURRENT_DATE())
    )

select constructor_name, count(constructor_name) as total_championships
from constructor_championships
where r_rank = 1
group by constructor_name
