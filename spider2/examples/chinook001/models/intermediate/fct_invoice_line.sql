{{ config(materialized="table", tags="fact") }}

SELECT * FROM {{ ref('stg_invoice_line') }}