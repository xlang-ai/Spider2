/*
Assumptions & reasoning (see guidelines comments requirement):
1.  The multipolygon representing Wikidata Q191 (Estonia) is stored in
    GEO_OPENSTREETMAP.PLANET_FEATURES with feature_type = 'multipolygons'.
    We fetch its (single) geometry as our target area.
2.  “Same geographic area” is interpreted as geometries that intersect
    the Estonia multipolygon – ST_INTERSECTS is therefore used.
3.  Candidates are all multipolygons from the same table that  (a) have
    a non-NULL geometry, (b) do NOT carry any tag with key = 'wikidata'.
4.   all_tags is a JSON array; to avoid expensive LATERAL FLATTEN scans
    on the full table we first pre-filter with NOT ILIKE '%"wikidata"%'.
    The small subset that passes the spatial test is then flattened once
    to extract the *name* tag.
5.  Point features are taken from PLANET_FEATURES_POINTS.  Only points
    with a non-NULL geometry are considered.  ST_CONTAINS(g_poly , g_pt)
    gives the per-polygon contained-point count.
6.  We order by descending point count and return the top two with their
    names (may be NULL if no name tag exists).
*/
WITH target_estonia AS (
    /* geometry of the multipolygon tagged wikidata = Q191 (Estonia) */
    SELECT  TO_GEOGRAPHY(pf."geometry") AS geom
    FROM    "GEO_OPENSTREETMAP"."GEO_OPENSTREETMAP"."PLANET_FEATURES" pf
            ,LATERAL FLATTEN(input => pf."all_tags") tag
    WHERE   pf."feature_type" = 'multipolygons'
      AND   tag.value:"key"::string  = 'wikidata'
      AND   tag.value:"value"::string = 'Q191'
    LIMIT 1
), candidate_raw AS (
    /* multipolygons without a wikidata tag, having geometry, intersecting Estonia */
    SELECT  COALESCE(pf."osm_way_id", pf."osm_id")      AS id,
            pf."geometry"                                 AS geom_bin,
            pf."all_tags"                                 AS tags
    FROM    "GEO_OPENSTREETMAP"."GEO_OPENSTREETMAP"."PLANET_FEATURES" pf
            CROSS JOIN target_estonia t
    WHERE   pf."feature_type" = 'multipolygons'
      AND   pf."geometry" IS NOT NULL
      AND   LOWER(TO_VARCHAR(pf."all_tags")) NOT ILIKE '%"wikidata"%'
      AND   ST_INTERSECTS(TO_GEOGRAPHY(pf."geometry"), t.geom)
), name_tags AS (
    /* extract (optional) name tag for every candidate */
    SELECT  cr.id,
            MAX(tag.value:"value"::string) AS name_tag
    FROM    candidate_raw cr,
            LATERAL FLATTEN(input => cr.tags) tag
    WHERE   tag.value:"key"::string = 'name'
    GROUP BY cr.id
), geom_candidates AS (
    SELECT  id, TO_GEOGRAPHY(geom_bin) AS geom
    FROM    candidate_raw
), point_counts AS (
    SELECT  gc.id                         AS multipolygon_id,
            nt.name_tag                   AS name,
            COUNT(*)                      AS point_cnt
    FROM        geom_candidates gc
    LEFT JOIN   name_tags nt   ON nt.id = gc.id
    JOIN        "GEO_OPENSTREETMAP"."GEO_OPENSTREETMAP"."PLANET_FEATURES_POINTS" p
                ON p."geometry" IS NOT NULL
               AND ST_CONTAINS(gc.geom, TO_GEOGRAPHY(p."geometry"))
    GROUP BY gc.id, nt.name_tag
)
SELECT   multipolygon_id AS id,
         name,
         point_cnt
FROM     point_counts
ORDER BY point_cnt DESC, name
LIMIT 2;