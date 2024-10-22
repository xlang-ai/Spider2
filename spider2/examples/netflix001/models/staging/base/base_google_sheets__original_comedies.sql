WITH source AS (
    SELECT * 
    FROM {{ source('google_sheets', 'GOOGLE_SHEETS__ORIGINAL_COMEDIES') }}
),

standardized AS (
    -- saving data standardization/cleaning for after union (to stay DRY)
    SELECT 
        title,
        2 AS category_id,
        genre,
        premiere,
        seasons,
        runtime,
        status,
        Updated_at AS updated_at
    FROM source
)

SELECT * 
FROM standardized
