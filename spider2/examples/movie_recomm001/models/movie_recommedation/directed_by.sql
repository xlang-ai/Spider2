-- get those cast in all_casts with job_id = 21 (director)
--
SELECT movie_id AS ":SRC_VID(string)", concat('p_', all_casts."person_id") AS ":DST_VID(string)"
FROM all_casts
WHERE job_id = 21
