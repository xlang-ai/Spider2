-- get movies and filter only title in english
--
SELECT movie_id AS ":VID(string)", name AS "movie.name"
FROM all_movie_aliases_iso
WHERE language_iso_639_1 = 'en'
