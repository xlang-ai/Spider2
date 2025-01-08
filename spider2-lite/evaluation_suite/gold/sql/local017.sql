WITH AnnualTotals AS (
    SELECT 
        STRFTIME('%Y', collision_date) AS Year, 
        COUNT(case_id) AS AnnualTotal
    FROM 
        collisions
    GROUP BY 
        Year
),
CategoryTotals AS (
    SELECT 
        STRFTIME('%Y', collision_date) AS Year,
        pcf_violation_category AS Category,
        COUNT(case_id) AS Subtotal
    FROM 
        collisions
    GROUP BY 
        Year, Category
),
CategoryPercentages AS (
    SELECT 
        ct.Year,
        ct.Category,
        ROUND((ct.Subtotal * 100.0) / at.AnnualTotal, 1) AS PercentageOfAnnualRoadIncidents
    FROM 
        CategoryTotals ct
    JOIN 
        AnnualTotals at ON ct.Year = at.Year
),
RankedCategories AS (
    SELECT
        Year,
        Category,
        PercentageOfAnnualRoadIncidents,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY PercentageOfAnnualRoadIncidents DESC) AS Rank
    FROM
        CategoryPercentages
),
TopTwoCategories AS (
    SELECT
        Year,
        GROUP_CONCAT(Category, ', ') AS TopCategories
    FROM
        RankedCategories
    WHERE
        Rank <= 2
    GROUP BY
        Year
),
UniqueYear AS (
    SELECT
        Year
    FROM
        TopTwoCategories
    GROUP BY
        TopCategories
    HAVING COUNT(Year) = 1
),
results AS (
SELECT 
    rc.Year, 
    rc.Category, 
    rc.PercentageOfAnnualRoadIncidents
FROM 
    UniqueYear u
JOIN 
    RankedCategories rc ON u.Year = rc.Year
WHERE 
    rc.Rank <= 2
)

SELECT distinct Year FROM results