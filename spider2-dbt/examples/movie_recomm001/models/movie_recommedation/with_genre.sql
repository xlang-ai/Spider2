-- add prefix "g_" for category_id from movie_categories table
-- "movie_id","category_id"

SELECT movie_id AS ":SRC_VID(string)", concat('g_', movie_categories."category_id") AS ":DST_VID(string)"
FROM movie_categories
