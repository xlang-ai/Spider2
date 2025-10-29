SELECT COUNT(DISTINCT input_sessions."session") as unique_sessions
FROM (
    SELECT DISTINCT "session", "stamp"
    FROM "LOG"."LOG"."FORM_LOG"
    WHERE "path" = '/regist/input'
) as input_sessions
INNER JOIN (
    SELECT DISTINCT "session", "stamp"
    FROM "LOG"."LOG"."FORM_LOG"
    WHERE "path" = '/regist/confirm'
) as confirm_sessions
    ON input_sessions."session" = confirm_sessions."session"
WHERE input_sessions."stamp" < confirm_sessions."stamp"