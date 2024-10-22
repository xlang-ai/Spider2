{{ config(materialized="view", tags="staging") }}

SELECT employee_id,
       last_name AS employee_last_name,
       first_name AS employee_first_name,
       title AS employee_title,
       reports_to AS employee_reports_to,
       birth_date AS employee_birth_date,
       hire_date AS employee_hire_date,
       address AS employee_address,
       city AS employee_city,
       state AS employee_state,
       country AS employee_country,
       postal_code AS employee_postal_code,
       phone AS employee_phone,
       fax AS employee_fax,
       email AS employee_email
 FROM {{ source('main', 'employee') }}