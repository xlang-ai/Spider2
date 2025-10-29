WITH RECURSIVE exploded (root_id, child_id, qty) AS (
    SELECT
        pr."packaging_id",
        pr."contains_id",
        pr."qty"
    FROM "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS" AS pr
    WHERE pr."packaging_id" NOT IN (
        SELECT "contains_id"
        FROM "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS"
        WHERE "contains_id" IS NOT NULL
    )
    UNION ALL
    SELECT
        exploded.root_id,
        pr2."contains_id",
        exploded.qty * pr2."qty"
    FROM exploded
    JOIN "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS" AS pr2
        ON pr2."packaging_id" = exploded.child_id
),
leaf_nodes AS (
    SELECT DISTINCT pr."contains_id" AS leaf_id
    FROM "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS" AS pr
    WHERE pr."contains_id" NOT IN (
        SELECT "packaging_id"
        FROM "ORACLE_SQL"."ORACLE_SQL"."PACKAGING_RELATIONS"
        WHERE "packaging_id" IS NOT NULL
    )
),
root_totals AS (
    SELECT
        exploded.root_id,
        SUM(exploded.qty) AS total_leaf_qty
    FROM exploded
    JOIN leaf_nodes
        ON leaf_nodes.leaf_id = exploded.child_id
    GROUP BY exploded.root_id
)
SELECT AVG(total_leaf_qty) AS average_total_quantity
FROM root_totals;