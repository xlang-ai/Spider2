{{ config(materialized="view", tags="staging") }}

SELECT media_type_id,
       name AS media_type_name
  FROM {{ source('main', 'media_type') }}