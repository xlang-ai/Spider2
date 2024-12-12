{{ config(materialized="view", tags="staging") }}

SELECT customer_id,
       first_name AS customer_first_name,
       last_name AS customer_last_name,
       company AS customer_company,
       address AS customer_address,
       city AS customer_city,
       state AS customer_state,
       country AS customer_country,
       postal_code AS customer_postal_code,
       phone AS customer_phone,
       fax AS customer_fax,
       email AS customer_email,
       support_rep_id AS employee_id
  FROM {{ source('main', 'customer') }}