-- get genres and filter only name in english

SELECT concat('g_', category_names."category_id") AS ":VID(string)", name AS "genre.name"
FROM category_names
WHERE language_iso_639_1 = 'en'
