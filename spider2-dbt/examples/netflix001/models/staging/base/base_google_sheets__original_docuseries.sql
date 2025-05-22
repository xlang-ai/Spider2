WITH source AS (
    SELECT * 
    FROM {{ source('google_sheets', 'GOOGLE_SHEETS__ORIGINAL_DOCUSERIES') }}
),

standardized AS (
    -- saving data standardization/cleaning for after union (to stay DRY)
    SELECT 
        title,
        3 AS category_id,
        Subject AS genre,
        premiere,
        seasons,
        runtime,
        status,
        Updated_at AS updated_at
    FROM source
)

SELECT * 
FROM standardized
