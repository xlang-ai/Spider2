WITH A AS (
    SELECT
        reference_bases,
        start_position
    FROM
        `spider2-public-data.human_genome_variants.1000_genomes_phase_3_optimized_schema_variants_20150220`
    WHERE
        reference_bases IN ('AT', 'TA')
),
B AS (
    SELECT
        reference_bases,
        MIN(start_position) AS min_start_position,
        MAX(start_position) AS max_start_position,
        COUNT(1) AS total_count
    FROM
        A
    GROUP BY
        reference_bases
),
min_counts AS (
    SELECT
        reference_bases,
        start_position AS min_start_position,
        COUNT(1) AS min_count
    FROM
        A
    GROUP BY
        reference_bases, start_position
    HAVING
        start_position = (SELECT MIN(start_position) FROM A AS sub WHERE sub.reference_bases = A.reference_bases)
),
max_counts AS (
    SELECT
        reference_bases,
        start_position AS max_start_position,
        COUNT(1) AS max_count
    FROM
        A
    GROUP BY
        reference_bases, start_position
    HAVING
        start_position = (SELECT MAX(start_position) FROM A AS sub WHERE sub.reference_bases = A.reference_bases)
)
SELECT
    B.reference_bases,
    B.min_start_position,
    CAST(min_counts.min_count AS FLOAT64) / B.total_count AS min_position_ratio,
    B.max_start_position,
    CAST(max_counts.max_count AS FLOAT64) / B.total_count AS max_position_ratio
FROM
    B
LEFT JOIN
    min_counts ON B.reference_bases = min_counts.reference_bases AND B.min_start_position = min_counts.min_start_position
LEFT JOIN
    max_counts ON B.reference_bases = max_counts.reference_bases AND B.max_start_position = max_counts.max_start_position
ORDER BY
    B.reference_bases;