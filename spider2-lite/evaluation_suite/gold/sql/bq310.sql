WITH
tags_to_use AS (
    SELECT tag, idx
    FROM UNNEST([
        'android-layout', 
        'android-activity', 
        'android-intent', 
        'android-edittext', 
        'android-fragments', 
        'android-recyclerview', 
        'listview', 
        'android-actionbar', 
        'google-maps', 
        'android-asynctask'
    ]) AS tag WITH OFFSET idx
),
android_how_to_questions AS (
    SELECT
        PQ.*
    FROM
        `bigquery-public-data.stackoverflow.posts_questions` PQ
    WHERE
        EXISTS (
            SELECT 1
            FROM UNNEST(SPLIT(PQ.tags, '|')) tag
            WHERE tag IN (SELECT tag FROM tags_to_use)
        )
        AND (LOWER(PQ.title) LIKE '%how%' OR LOWER(PQ.body) LIKE '%how%')
),
most_viewed_question AS (
    SELECT
        T.id AS tag_id,
        T.tag_name,
        Q.id AS question_id,
        Q.title,
        Q.tags,
        Q.view_count
    FROM
        `bigquery-public-data.stackoverflow.tags` T
    INNER JOIN
        tags_to_use TTU ON T.tag_name = TTU.tag
    INNER JOIN
        android_how_to_questions Q ON T.tag_name IN UNNEST(SPLIT(Q.tags, '|'))
    ORDER BY Q.view_count DESC
    LIMIT 1
)
SELECT
    title
FROM
    most_viewed_question;