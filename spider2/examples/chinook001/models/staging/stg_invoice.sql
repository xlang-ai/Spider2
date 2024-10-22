{{ config(materialized="view", tags="staging") }}

SELECT invoice_id,
       customer_id,
       invoice_date,
       billing_address AS invoice_billing_address,
       billing_city AS invoice_billing_city,
       billing_state AS invoice_billing_state,
       billing_country AS invoice_billing_country,
       billing_postal_code AS invoice_billing_postal_code,
       total AS invoice_total
  FROM {{ source('main', 'invoice') }}