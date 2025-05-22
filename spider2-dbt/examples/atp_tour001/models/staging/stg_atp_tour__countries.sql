{{ config(
    tags=["staging"]
  )
}}

with atp_tour_countries as (
    select *
      from {{ source('atp_tour', 'countries') }}
)
, renamed as (
    select cca3::varchar(3) as country_iso_code
          ,name.common::varchar(100) as country_name
          ,demonyms.eng.f::varchar(100) as nationality
          ,region::varchar(100) as continent
          ,subregion::varchar(100) as region
          ,flag::varchar(100) as flag
          ,population::int as population
          ,coalesce(json_array_length(borders), 0)::int as num_of_borders
      from atp_tour_countries
)
, surrogate_keys as (
    select {{ dbt_utils.surrogate_key(['country_iso_code']) }} as country_sk
          ,*
      from renamed
)
select *
  from surrogate_keys