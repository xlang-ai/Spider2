-- get people and add "p_" prefix to id
-- "id","name","birthday","deathday","gender"
SELECT concat('p_', all_people."id") AS ":VID(string)", name AS "person.name", birthday AS "person.birthdate"
FROM all_people
