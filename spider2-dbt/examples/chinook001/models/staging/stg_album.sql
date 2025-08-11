{{ config(materialized="view", tags="staging") }}

SELECT album_id,
       title AS album_title,
       artist_id
  FROM {{ source('main', 'album') }}