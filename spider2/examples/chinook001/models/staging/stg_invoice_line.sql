{{ config(materialized="view", tags="staging") }}

SELECT invoice_line_id,
       invoice_id,
       track_id AS track_id,
       unit_price AS track_unit_price,
       quantity AS track_quantity
  FROM {{ source('main', 'invoice_line') }}