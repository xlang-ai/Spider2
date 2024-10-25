with base_airports as (

    select * from {{ ref('base_airports') }}

),

base_dist as (

    select
        a."name"                                    as a_name,
        b."name"                                    as b_name,
        a.latitude                                  as a_lat,
        a.longitude                                 as a_lon,
        b.latitude                                  as b_lat,
        b.longitude                                 as b_lon,
        (b.latitude - a.latitude) * pi() / 180      as lat_dist,
        (b.longitude - a.longitude) * pi() / 180    as lon_dist

    from
        base_airports a

        cross join
            base_airports b

    where
        a.country = 'Malaysia'
    and
        b.country = 'Malaysia'

    order by
        1,
        2

),

base_area as (

    select
        *,
        sin(lat_dist / 2) * sin(lat_dist / 2)
            + ((a_lat) * pi() / 180)
                * ((b_lat) * pi() / 180)
                    * sin(lon_dist / 2)
                        * sin(lon_dist / 2)     as area

    from
        base_dist

),

distance as (

    select
        a_name,
        replace(b_name, ' ', '_') as b_name,
        6371 * 2 * atan2(sqrt(area), sqrt(1-area) ) as distance_km

    from
        base_area

    order by
        1,
        2

)

select * from distance