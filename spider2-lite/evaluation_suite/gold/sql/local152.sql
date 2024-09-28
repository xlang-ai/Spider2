WITH movie_date_info AS
(
    SELECT d.name_id, n.name, d.movie_id,
           m.date_published, 
           (SELECT MIN(m2.date_published)
            FROM director_mapping d2
            JOIN movies m2 ON d2.movie_id = m2.id
            WHERE d2.name_id = d.name_id 
            AND m2.date_published > m.date_published) AS next_movie_date
    FROM director_mapping d
    JOIN names AS n ON d.name_id = n.id
    JOIN movies AS m ON d.movie_id = m.id
),

date_difference AS
(
    SELECT *, 
           JULIANDAY(next_movie_date) - JULIANDAY(date_published) AS diff
    FROM movie_date_info
),
 
avg_inter_days AS
(
    SELECT name_id, AVG(diff) AS avg_inter_movie_days
    FROM date_difference
    WHERE diff IS NOT NULL
    GROUP BY name_id
),

final_result_table AS
(
    SELECT d.name_id AS director_id,
           n.name AS director_name,
           COUNT(d.movie_id) AS number_of_movies,
           ROUND(a.avg_inter_movie_days) AS inter_movie_days,
           ROUND(AVG(r.avg_rating), 2) AS avg_rating,
           SUM(r.total_votes) AS total_votes,
           MIN(r.avg_rating) AS min_rating,
           MAX(r.avg_rating) AS max_rating,
           SUM(m.duration) AS total_duration,
           ROW_NUMBER() OVER(ORDER BY COUNT(d.movie_id) DESC) AS director_row_rank
    FROM names AS n 
    JOIN director_mapping AS d ON n.id = d.name_id
    JOIN ratings AS r ON d.movie_id = r.movie_id
    JOIN movies AS m ON m.id = r.movie_id
    JOIN avg_inter_days AS a ON a.name_id = d.name_id
    GROUP BY director_id
)

SELECT *
FROM final_result_table
ORDER BY director_row_rank
LIMIT 9;
