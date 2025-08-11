{{ config(materialized="view", tags="staging") }}

SELECT * FROM {{ source('main', 'playlist_track') }}