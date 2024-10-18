WITH FIRST_OA AS (
    SELECT
        T1.app_id,
        T1.mail_dt,
        T1.ifw_number
    FROM 
        `patents-public-data.uspto_oce_office_actions.office_actions` T1
    INNER JOIN (
        SELECT 
            app_id, 
            MIN(mail_dt) AS date
        FROM 
            `patents-public-data.uspto_oce_office_actions.office_actions`
        WHERE 
            rejection_101 = '1' AND 
            allowed_claims = '0'
        GROUP BY 
            app_id
    ) T2 ON T1.app_id = T2.app_id AND T1.mail_dt = T2.date
    ORDER BY 
        app_id
),

GRNT AS (
    SELECT
        application_number,
        grant_date
    FROM 
        `spider2-public-data.patents.publications`
    WHERE
        grant_date > 20100000
        AND grant_date < 20240000
        AND country_code = 'US'
),

AS_FILED AS (
    SELECT
        PUB.application_number,
        PUB.publication_number,
        MIN(publication_date) AS first_pub_date,
        claims.text AS filed_claims
    FROM 
        `spider2-public-data.patents.publications` AS PUB,
        UNNEST(claims_localized) AS claims
    JOIN GRNT ON GRNT.application_number = PUB.application_number

    GROUP BY 
        PUB.application_number, 
        PUB.publication_number, 
        claims.text
)

SELECT
    AS_FILED.publication_number AS first_pub_no,
    AS_FILED.first_pub_date,
    LENGTH(AS_FILED.filed_claims) AS length_of_filed_claims,
    GRNT.grant_date
FROM 
    `patents-public-data.uspto_oce_office_actions.office_actions` AS OA
INNER JOIN FIRST_OA ON OA.ifw_number = FIRST_OA.ifw_number
JOIN `patents-public-data.uspto_oce_office_actions.match_app` AS APP ON OA.app_id = APP.app_id
JOIN AS_FILED ON APP.application_number = AS_FILED.application_number
JOIN GRNT ON APP.application_number = GRNT.application_number
ORDER BY 
    length_of_filed_claims DESC
LIMIT 5;