{{ config(materialized='table') }}

with berlin_bezirke as (
    select *
    from {{ source('main', 'berlin_bezirke') }}
), 

berlin_lor_geo as (
    select *
    from {{ source('main','mapping_berlin_lor') }}
)

select 
    -- identifiers
    cast(berlin_lor_geo.object_id as integer) as object_id,
    cast(berlin_lor_geo.bezirk_id as integer) as bezirk_id,
    cast(berlin_bezirke.bezirk_name as string) as bezirk_name,
    cast(berlin_lor_geo.pgr_id as integer) as pgr_id,
    cast(berlin_lor_geo.plr_id as integer) as plr_id,

    -- additional information
    cast(berlin_lor_geo.pgr_name as string) as pgr_name,
    cast(berlin_lor_geo.bzr_name as string) as bzr_name,
    cast(berlin_lor_geo.plr_name as string) as plr_name,
    cast(berlin_lor_geo.stand as string) as stand,

    -- geo information
    cast(berlin_lor_geo.plr_geometry as string) as plr_geometry

from berlin_lor_geo
left join berlin_bezirke 
on berlin_lor_geo.bezirk_id = berlin_bezirke.bez_id

