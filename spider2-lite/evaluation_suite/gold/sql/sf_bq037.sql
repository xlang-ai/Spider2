WITH A AS (
    SELECT
        "reference_bases",
        "start_position"
    FROM
        "HUMAN_GENOME_VARIANTS"."HUMAN_GENOME_VARIANTS"."_1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220"
    WHERE
        "reference_bases" IN ('AT', 'TA')
),
B AS (
    SELECT
        "reference_bases",
        MIN("start_position") AS "min_start_position",
        MAX("start_position") AS "max_start_position",
        COUNT(1) AS "total_count"
    FROM
        A
    GROUP BY
        "reference_bases"
),
min_counts AS (
    SELECT
        A."reference_bases",  -- Explicitly referencing the column from table A
        A."start_position" AS "min_start_position",
        COUNT(1) AS "min_count"
    FROM
        A
    INNER JOIN B 
        ON A."reference_bases" = B."reference_bases"
    WHERE
        A."start_position" = B."min_start_position"
    GROUP BY
        A."reference_bases", A."start_position"
),
max_counts AS (
    SELECT
        A."reference_bases",  -- Explicitly referencing the column from table A
        A."start_position" AS "max_start_position",
        COUNT(1) AS "max_count"
    FROM
        A
    INNER JOIN B
        ON A."reference_bases" = B."reference_bases"
    WHERE
        A."start_position" = B."max_start_position"
    GROUP BY
        A."reference_bases", A."start_position"
)
SELECT
    B."reference_bases",  -- Explicitly referencing the column from table B
    B."min_start_position",
    CAST(min_counts."min_count" AS FLOAT) / B."total_count" AS "min_position_ratio",
    B."max_start_position",
    CAST(max_counts."max_count" AS FLOAT) / B."total_count" AS "max_position_ratio"
FROM
    B
LEFT JOIN
    min_counts ON B."reference_bases" = min_counts."reference_bases" AND B."min_start_position" = min_counts."min_start_position"
LEFT JOIN
    max_counts ON B."reference_bases" = max_counts."reference_bases" AND B."max_start_position" = max_counts."max_start_position"
ORDER BY
    B."reference_bases";
