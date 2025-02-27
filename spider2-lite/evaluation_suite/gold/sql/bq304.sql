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
        bigquery-public-data.stackoverflow.posts_questions PQ
    WHERE
        EXISTS (
            SELECT 1
            FROM UNNEST(SPLIT(PQ.tags, '|')) tag
            WHERE tag IN (SELECT tag FROM tags_to_use)
        )
        AND (LOWER(PQ.title) LIKE '%how%' OR LOWER(PQ.body) LIKE '%how%')
        AND NOT (LOWER(PQ.title) LIKE '%fail%' OR LOWER(PQ.title) LIKE '%problem%' OR LOWER(PQ.title) LIKE '%error%'
                 OR LOWER(PQ.title) LIKE '%wrong%' OR LOWER(PQ.title) LIKE '%fix%' OR LOWER(PQ.title) LIKE '%bug%'
                 OR LOWER(PQ.title) LIKE '%issue%' OR LOWER(PQ.title) LIKE '%solve%' OR LOWER(PQ.title) LIKE '%trouble%')
        AND NOT (LOWER(PQ.body) LIKE '%fail%' OR LOWER(PQ.body) LIKE '%problem%' OR LOWER(PQ.body) LIKE '%error%'
                 OR LOWER(PQ.body) LIKE '%wrong%' OR LOWER(PQ.body) LIKE '%fix%' OR LOWER(PQ.body) LIKE '%bug%'
                 OR LOWER(PQ.body) LIKE '%issue%' OR LOWER(PQ.body) LIKE '%solve%' OR LOWER(PQ.body) LIKE '%trouble%')
),
questions_with_tag_rankings AS (
    SELECT
        T.id AS tag_id,
        TTU.idx AS tag_offset,
        T.tag_name,
        T.wiki_post_id AS tag_wiki_post_id,
        Q.id AS question_id,
        Q.title,
        Q.tags,
        Q.view_count,
        RANK() OVER (PARTITION BY T.id ORDER BY Q.view_count DESC) AS question_view_count_rank,
        COUNT(*) OVER (PARTITION BY T.id) AS total_valid_questions
    FROM
        bigquery-public-data.stackoverflow.tags T
    INNER JOIN
        tags_to_use TTU ON T.tag_name = TTU.tag
    INNER JOIN
        android_how_to_questions Q ON T.tag_name IN UNNEST(SPLIT(Q.tags, '|'))
)
SELECT
    question_id
FROM
    questions_with_tag_rankings
WHERE
    question_view_count_rank <= 50 AND total_valid_questions >= 50
ORDER BY
    tag_offset ASC, question_view_count_rank ASC;
