WITH "DIRECTED" AS (
  SELECT
    "v"."FromUserId" AS "FROM_USER_ID",
    "v"."ToUserId" AS "TO_USER_ID",
    COUNT(DISTINCT "v"."ForumMessageId") AS "RECEIVED_CNT"
  FROM "META_KAGGLE"."META_KAGGLE"."FORUMMESSAGEVOTES" AS "v"
  WHERE "v"."FromUserId" IS NOT NULL
    AND "v"."ToUserId" IS NOT NULL
    AND "v"."FromUserId" != "v"."ToUserId"
  GROUP BY "v"."FromUserId", "v"."ToUserId"
)
SELECT
  COALESCE("u_from"."UserName", "u_from"."DisplayName") AS "GiverUserName",
  COALESCE("u_to"."UserName", "u_to"."DisplayName") AS "ReceiverUserName",
  "d"."RECEIVED_CNT" AS "ReceivedUpvotes",
  COALESCE("d2"."RECEIVED_CNT", 0) AS "ReturnedUpvotes"
FROM "DIRECTED" AS "d"
LEFT JOIN "DIRECTED" AS "d2"
  ON "d2"."FROM_USER_ID" = "d"."TO_USER_ID"
 AND "d2"."TO_USER_ID" = "d"."FROM_USER_ID"
LEFT JOIN "META_KAGGLE"."META_KAGGLE"."USERS" AS "u_from"
  ON "u_from"."Id" = "d"."FROM_USER_ID"
LEFT JOIN "META_KAGGLE"."META_KAGGLE"."USERS" AS "u_to"
  ON "u_to"."Id" = "d"."TO_USER_ID"
ORDER BY "d"."RECEIVED_CNT" DESC,
         COALESCE("d2"."RECEIVED_CNT", 0) DESC
FETCH FIRST 1 ROWS ONLY;