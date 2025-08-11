{{ config(enabled=var('seed_source', true)) }}

SELECT * FROM {{ ref('stg_vocabulary__vocabulary') }}
