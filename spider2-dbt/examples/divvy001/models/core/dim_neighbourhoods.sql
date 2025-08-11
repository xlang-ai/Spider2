{{ config(materialized='table') }}

select *
from {{ source('main','divvy_stations_lookup')}}
