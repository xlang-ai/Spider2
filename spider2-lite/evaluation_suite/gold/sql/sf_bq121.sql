WITH sub AS (
  SELECT 
    "users"."id",
    CAST(TO_TIMESTAMP(MAX("users"."creation_date") / 1000000.0) AS DATE) AS "user_creation_date",  -- 使用 MAX 聚合 creation_date 并转换为 DATE
    MAX("users"."reputation") AS "reputation",  
    SUM(CASE WHEN badges."user_id" IS NULL THEN 0 ELSE 1 END) AS "num_badges"
  FROM "STACKOVERFLOW"."STACKOVERFLOW"."USERS" "users"
  LEFT JOIN "STACKOVERFLOW"."STACKOVERFLOW"."BADGES" badges
    ON "users"."id" = badges."user_id"
  WHERE CAST(TO_TIMESTAMP("users"."creation_date" / 1000000.0) AS DATE) <= DATE '2021-10-01'
  GROUP BY "users"."id"
)

SELECT 
  DATEDIFF(YEAR, "user_creation_date", DATE '2021-10-01') AS "user_tenure",
  COUNT(1) AS "Num_Users",
  AVG("reputation") AS "Avg_Reputation",
  AVG("num_badges") AS "Avg_Num_Badges"
FROM sub
GROUP BY "user_tenure"
ORDER BY "user_tenure";
