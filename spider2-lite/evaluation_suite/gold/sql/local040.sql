WITH joined_trees AS (
    SELECT
        t.idx,
        t.tree_id,
        t.tree_dbh,
        t.stump_diam,
        t.status,
        t.health,
        t.spc_latin,
        t.spc_common,
        t.address,
        COALESCE(t.zipcode, it.zipcode) AS zipcode,
        t.borocode,
        t.boroname,
        t.nta_name,
        t.state,
        t.latitude,
        t.longitude,
        COALESCE(it.Estimate_Total, 0) AS estimate_total,
        COALESCE(it.Margin_of_Error_Total, 0) AS margin_of_error_total,
        COALESCE(it.Estimate_Median_income, 0) AS estimate_median_income,
        COALESCE(it.Margin_of_Error_Median_income, 0) AS margin_of_error_median_income,
        COALESCE(it.Estimate_Mean_income, 0) AS estimate_mean_income,
        COALESCE(it.Margin_of_Error_Mean_income, 0) AS margin_of_error_mean_income
    FROM 
        trees t
    LEFT JOIN 
        income_trees it ON t.zipcode = it.zipcode

    UNION

    SELECT
        NULL AS idx,
        NULL AS tree_id,
        NULL AS tree_dbh,
        NULL AS stump_diam,
        NULL AS status,
        NULL AS health,
        NULL AS spc_latin,
        NULL AS spc_common,
        NULL AS address,
        it.zipcode AS zipcode,
        NULL AS borocode,
        NULL AS boroname,
        NULL AS nta_name,
        NULL AS state,
        NULL AS latitude,
        NULL AS longitude,
        it.Estimate_Total AS estimate_total,
        it.Margin_of_Error_Total AS margin_of_error_total,
        it.Estimate_Median_income AS estimate_median_income,
        it.Margin_of_Error_Median_income AS margin_of_error_median_income,
        it.Estimate_Mean_income AS estimate_mean_income,
        it.Margin_of_Error_Mean_income AS margin_of_error_mean_income
    FROM 
        income_trees it
    LEFT JOIN 
        trees t ON t.zipcode = it.zipcode
    WHERE 
        t.zipcode IS NULL
)


SELECT
    jt.boroname,
    AVG(jt.estimate_mean_income) AS mean_income
FROM
    joined_trees jt
JOIN (
    SELECT
        boroname,
        COUNT(tree_id) AS count_trees
    FROM
        joined_trees
    WHERE
        estimate_median_income > 0 AND estimate_mean_income > 0 AND boroname IS NOT NULL
    GROUP BY
        boroname
    ORDER BY
        count_trees DESC
    LIMIT 3
) AS tree_counts
ON jt.boroname = tree_counts.boroname
WHERE
    jt.estimate_mean_income > 0
GROUP BY
    jt.boroname
ORDER BY
    mean_income DESC;