WITH RECURSIVE RECURSIVE_PR (root_id, packaging_id, contains_id, qty, lvl) AS (
    SELECT
        PR."packaging_id" AS root_id,
        PR."packaging_id",
        PR."contains_id",
        PR."qty",
        1 AS lvl
    FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS PR
    WHERE PR."packaging_id" NOT IN (
        SELECT C."contains_id" FROM ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS C
    )
    UNION ALL
    SELECT
        RPR.root_id,
        PR."packaging_id",
        PR."contains_id",
        RPR.qty * PR."qty" AS qty,
        RPR.lvl + 1 AS lvl
    FROM RECURSIVE_PR RPR
    JOIN ORACLE_SQL.ORACLE_SQL.PACKAGING_RELATIONS PR ON PR."packaging_id" = RPR.contains_id
),
RANKED_RECURSIVE_PR AS (
    SELECT
        RPR.*,
        ROW_NUMBER() OVER (PARTITION BY RPR.root_id ORDER BY RPR.lvl) AS rpr_order
    FROM RECURSIVE_PR RPR
),
LEAF AS (
    SELECT
        RRP.*,
        CASE
            WHEN COALESCE(
                (SELECT MIN(lvl) FROM RANKED_RECURSIVE_PR WHERE root_id = RRP.root_id AND lvl > RRP.lvl),
                0
            ) > RRP.lvl THEN 0
            ELSE 1
        END AS is_leaf
    FROM RANKED_RECURSIVE_PR RRP
),
PACKAGING_COMBINATION_QUANTITIES AS (
    SELECT
        P."id" AS packaging_id,
        C."id" AS contained_item_id,
        SUM(LEAF.qty) AS total_qty
    FROM LEAF
    JOIN ORACLE_SQL.ORACLE_SQL.PACKAGING P ON P."id" = LEAF.root_id
    JOIN ORACLE_SQL.ORACLE_SQL.PACKAGING C ON C."id" = LEAF.contains_id
    WHERE LEAF.is_leaf = 1
    GROUP BY P."id", C."id"
)
SELECT
    ROUND(AVG(total_qty), 2) AS avg_qty
FROM PACKAGING_COMBINATION_QUANTITIES;
