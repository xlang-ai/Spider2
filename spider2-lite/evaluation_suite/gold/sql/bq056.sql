DECLARE var_State            STRING DEFAULT 'CA';
DECLARE var_RoadTypes ARRAY<STRING> DEFAULT ['motorway', 'trunk','primary', 'secondary','residential'];


with t_state_geo as (
    select State
         , state_geom as StateGeography
      from `bigquery-public-data.geo_us_boundaries.states`
     where LOWER(State) = LOWER(var_State)
)
, t_roads as (
    select distinct Id as WayId
      from `spider2-public-data.geo_openstreetmap.planet_ways` pw, pw.all_tags as tag
     where LOWER(tag.Key) = 'highway'
       and LOWER(tag.Value) in UNNEST(var_RoadTypes)
)
, t_state_ways as (
    select pw.Id       as WayId
         , pw.geometry as WayGeography
         , pw.Nodes    as WayNodes
      from `spider2-public-data.geo_openstreetmap.planet_ways` pw
      join t_state_geo ts
        on ST_CONTAINS(ts.StateGeography, pw.geometry)
      join t_roads tr
        on pw.Id = tr.WayId
)
, t_touching_ways as (
    select    LEAST(t1.WayId, t2.WayId) as WayId
         , GREATEST(t1.WayId, t2.WayId) as TouchingWayId
         , t1.WayNodes, t2.WayNodes as TouchingWayNodes
      from t_state_ways t1
      join t_state_ways t2
        on ST_INTERSECTS(t1.WayGeography, t2.WayGeography)
     where not t1.WayId = t2.WayId
)
, t_sharing_nodes as (
    select distinct WayId, TouchingWayId
      from t_touching_ways t, t.WayNodes as WayNode
     where WayNode in UNNEST(TouchingWayNodes)
)
, t_overlapping_ways as (
    select distinct WayId, TouchingWayId
      from t_touching_ways tt
      left join t_sharing_nodes ts
     using (WayId, TouchingWayId)
     where ts.WayId is NULL
)
, t_with_metadata as (
    select WayId, TouchingWayId
         , pw1.all_tags as WayTags
         , pw2.all_tags as TouchingWayTags
         , pw1.geometry as WayGeography
         , pw2.geometry as TouchingWayGeography
      from t_overlapping_ways tw
      join `spider2-public-data.geo_openstreetmap.planet_ways` pw1
        on tw.WayId = pw1.Id
      join `spider2-public-data.geo_openstreetmap.planet_ways` pw2
        on tw.TouchingWayId = pw2.Id
)
, t_has_bridge_tag as (
    select distinct WayId, TouchingWayId
      from t_with_metadata t, t.WayTags as WayTag, t.TouchingWayTags as TouchingWayTag
     where (LOWER(TouchingWayTag.key) = 'bridge' and LOWER(TouchingWayTag.value) = 'yes')
        or (LOWER(WayTag.key) = 'bridge' and LOWER(WayTag.value) = 'yes')
)
, filtered_results as (
    select WayId, TouchingWayId
    from t_with_metadata tm
    left join t_has_bridge_tag tb
    using (WayId, TouchingWayId)
    where tb.WayId is NULL
)
SELECT COUNT(*) AS num_overlapping_ways
FROM filtered_results;