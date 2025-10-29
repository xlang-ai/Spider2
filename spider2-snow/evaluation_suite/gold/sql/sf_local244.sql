WITH stats AS (
    SELECT
        MIN("Milliseconds") / 60000.0 AS min_length,
        AVG("Milliseconds") / 60000.0 AS avg_length,
        MAX("Milliseconds") / 60000.0 AS max_length
    FROM "MUSIC"."MUSIC"."TRACK"
),
track_lengths AS (
    SELECT
        "TrackId",
        "Milliseconds" / 60000.0 AS length_minutes
    FROM "MUSIC"."MUSIC"."TRACK"
),
revenue AS (
    SELECT
        "TrackId",
        SUM("UnitPrice" * "Quantity") AS track_revenue
    FROM "MUSIC"."MUSIC"."INVOICELINE"
    GROUP BY "TrackId"
),
track_data AS (
    SELECT
        tl."TrackId",
        tl.length_minutes,
        COALESCE(rv.track_revenue, 0) AS track_revenue,
        st.min_length,
        st.avg_length,
        st.max_length,
        (st.min_length + st.avg_length) / 2 AS lower_midpoint,
        (st.avg_length + st.max_length) / 2 AS upper_midpoint
    FROM track_lengths tl
    CROSS JOIN stats st
    LEFT JOIN revenue rv ON tl."TrackId" = rv."TrackId"
)
SELECT
    CASE
        WHEN length_minutes < lower_midpoint THEN 'short'
        WHEN length_minutes < upper_midpoint THEN 'medium'
        ELSE 'long'
    END AS category,
    MIN(length_minutes) AS min_minutes,
    MAX(length_minutes) AS max_minutes,
    SUM(track_revenue) AS total_revenue
FROM track_data
GROUP BY category
ORDER BY category