with "denmark" as (
    select st_collect(to_geography("PF"."geometry")) as "geom"
    from "GEO_OPENSTREETMAP"."GEO_OPENSTREETMAP"."PLANET_FEATURES" as "PF",
         lateral flatten(input => "PF"."all_tags") as "TAG"
    where "PF"."feature_type" = 'multipolygons'
      and "TAG"."VALUE":"key"::string = 'wikidata'
      and "TAG"."VALUE":"value"::string = 'Q35'
),
"highway_lines_raw" as (
    select
        "PF"."osm_id" as "osm_id",
        "PF"."geometry" as "geometry",
        max(case when "TAG"."VALUE":"key"::string = 'highway' then "TAG"."VALUE":"value"::string end) as "highway_type"
    from "GEO_OPENSTREETMAP"."GEO_OPENSTREETMAP"."PLANET_FEATURES" as "PF",
         lateral flatten(input => "PF"."all_tags") as "TAG"
    where "PF"."feature_type" = 'lines'
    group by "PF"."osm_id", "PF"."geometry"
    having max(case when "TAG"."VALUE":"key"::string = 'highway' then "TAG"."VALUE":"value"::string end) is not null
),
"highway_lines" as (
    select
        "osm_id",
        to_geography("geometry") as "geom",
        "highway_type"
    from "highway_lines_raw"
),
"lengths" as (
    select
        "HL"."highway_type" as "highway_type",
        st_length(st_intersection("D"."geom", "HL"."geom")) as "length_m"
    from "highway_lines" as "HL"
    cross join "denmark" as "D"
    where st_intersects("D"."geom", "HL"."geom")
)
select
    "highway_type",
    sum("length_m") as "total_length_m"
from "lengths"
group by "highway_type"
order by "total_length_m" desc
limit 5;