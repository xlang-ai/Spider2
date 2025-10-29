WITH min_max AS (
    SELECT 
        "reference_bases",
        MIN("start_position") as min_start,
        MAX("start_position") as max_start,
        COUNT(*) as total_count
    FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220
    WHERE "reference_bases" IN ('AT', 'TA')
    GROUP BY "reference_bases"
),
min_counts AS (
    SELECT 
        v."reference_bases",
        v."start_position",
        COUNT(*) as extreme_count
    FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220 v
    INNER JOIN min_max mm ON v."reference_bases" = mm."reference_bases"
    WHERE v."start_position" = mm.min_start
    GROUP BY v."reference_bases", v."start_position"
),
max_counts AS (
    SELECT 
        v."reference_bases",
        v."start_position",
        COUNT(*) as extreme_count
    FROM HUMAN_GENOME_VARIANTS.HUMAN_GENOME_VARIANTS._1000_GENOMES_PHASE_3_OPTIMIZED_SCHEMA_VARIANTS_20150220 v
    INNER JOIN min_max mm ON v."reference_bases" = mm."reference_bases"
    WHERE v."start_position" = mm.max_start
    GROUP BY v."reference_bases", v."start_position"
)
SELECT 
    mm."reference_bases",
    mm.min_start,
    mm.max_start,
    COALESCE(mc.extreme_count, 0) * 1.0 / mm.total_count AS prop_min,
    COALESCE(mx.extreme_count, 0) * 1.0 / mm.total_count AS prop_max
FROM min_max mm
LEFT JOIN min_counts mc ON mm."reference_bases" = mc."reference_bases"
LEFT JOIN max_counts mx ON mm."reference_bases" = mx."reference_bases"
ORDER BY mm."reference_bases";