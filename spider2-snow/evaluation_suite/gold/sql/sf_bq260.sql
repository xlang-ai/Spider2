WITH FilteredUsers AS (
  SELECT
    "gender",
    "age"
  FROM "THELOOK_ECOMMERCE"."THELOOK_ECOMMERCE"."USERS"
  WHERE
    TO_TIMESTAMP_NTZ("created_at" / 1000000) >= '2019-01-01' AND TO_TIMESTAMP_NTZ("created_at" / 1000000) < '2022-05-01'
), AgeBounds AS (
  SELECT
    "gender",
    MIN("age") AS min_age,
    MAX("age") AS max_age
  FROM FilteredUsers
  GROUP BY
    "gender"
)
SELECT
  T1."gender",
  COUNT(CASE WHEN T1."age" = T2.min_age THEN 1 END) AS youngest_count,
  COUNT(CASE WHEN T1."age" = T2.max_age THEN 1 END) AS oldest_count
FROM FilteredUsers AS T1
JOIN AgeBounds AS T2
  ON T1."gender" = T2."gender"
WHERE
  T1."age" = T2.min_age OR T1."age" = T2.max_age
GROUP BY
  T1."gender";