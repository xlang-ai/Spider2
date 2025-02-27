With INFO AS (
SELECT 
  MR.patientId, 
  P.last_name,
  ARRAY_TO_STRING(P.first_name, " ") AS First_name,
  Condition.Codes, 
  Condition.Conditions,
  MR.med_count AS COUNT_NUMBER
FROM
  (SELECT 
    id, 
    name[safe_offset(0)].family as last_name, 
    name[safe_offset(0)].given as first_name, 
    TIMESTAMP(deceased.dateTime) AS deceased_datetime 
  FROM `bigquery-public-data.fhir_synthea.patient`) AS P
JOIN
  (SELECT  subject.patientId as patientId, 
           COUNT(DISTINCT medication.codeableConcept.coding[safe_offset(0)].code) AS med_count
   FROM    `bigquery-public-data.fhir_synthea.medication_request`
   WHERE   status = 'active'
   GROUP BY 1
   ) AS MR
ON MR.patientId = P.id 
JOIN
  (SELECT 
  PatientId, 
  STRING_AGG(DISTINCT condition_desc, ", ") AS Conditions, 
  STRING_AGG(DISTINCT condition_code, ", ") AS Codes
  FROM(
    SELECT 
      subject.patientId as PatientId, 
              code.coding[safe_offset(0)].code condition_code,
              code.coding[safe_offset(0)].display condition_desc
       FROM `bigquery-public-data.fhir_synthea.condition`
       wHERE 
         code.coding[safe_offset(0)].display = 'Diabetes'
         OR 
         code.coding[safe_offset(0)].display = 'Hypertension' 
    )
  GROUP BY PatientId
  ) AS Condition
ON MR.patientId = Condition.PatientId
WHERE med_count >= 7 
AND P.deceased_datetime is NULL /*only alive patients*/
GROUP BY patientId, last_name, first_name, Condition.Codes, Condition.Conditions, MR.med_count
ORDER BY last_name
)

SELECT COUNT(*) FROM INFO