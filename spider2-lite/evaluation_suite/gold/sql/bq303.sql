SELECT u_id, tags
FROM (
    -- select comments with tags from the post
    SELECT cm.u_id, cm.creation_date, cm.text, pq.tags, "comment" as type
    FROM (
            SELECT a.parent_id as q_id, c.user_id as u_id, c.creation_date as creation_date, c.text as text
            FROM `bigquery-public-data.stackoverflow.comments` as c
            INNER JOIN `bigquery-public-data.stackoverflow.posts_answers` as a ON (a.id = c.post_id)
            WHERE c.user_id BETWEEN 16712208 AND 18712208
              AND DATE(c.creation_date) BETWEEN '2019-07-01' AND '2019-12-31'
            
            UNION ALL 
            
            SELECT q.id as q_id, c.user_id as u_id, c.creation_date as creation_date, c.text as text
            FROM `bigquery-public-data.stackoverflow.comments` as c
            INNER JOIN `bigquery-public-data.stackoverflow.posts_questions` as q ON (q.id = c.post_id)
            WHERE c.user_id BETWEEN 16712208 AND 18712208
              AND DATE(c.creation_date) BETWEEN '2019-07-01' AND '2019-12-31'
        ) as cm
    INNER JOIN `bigquery-public-data.stackoverflow.posts_questions` as pq ON (pq.id = cm.q_id)
        
    UNION ALL
    -- select answers with tags related to the post
    SELECT pa.owner_user_id as u_id, pa.creation_date as creation_date, pa.body as text, pq.tags as tags, "answer" as type
    FROM `bigquery-public-data.stackoverflow.posts_answers` as pa
    LEFT OUTER JOIN `bigquery-public-data.stackoverflow.posts_questions` as pq ON pq.id = pa.parent_id
    WHERE pa.owner_user_id BETWEEN 16712208 AND 18712208
      AND DATE(pa.creation_date) BETWEEN '2019-07-01' AND '2019-12-31'
    
    UNION ALL
    -- select posts
    SELECT pq.owner_user_id as u_id, pq.creation_date as creation_date, pq.body as text, pq.tags as tags, "question" as type
    FROM `bigquery-public-data.stackoverflow.posts_questions` as pq
    WHERE pq.owner_user_id BETWEEN 16712208 AND 18712208
      AND DATE(pq.creation_date) BETWEEN '2019-07-01' AND '2019-12-31'
)
ORDER BY u_id, creation_date;

