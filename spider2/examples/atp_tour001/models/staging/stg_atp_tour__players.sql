{{ config(
    tags=["staging"]
  )
}}

with atp_tour_players as (
    select *
      from {{ source('atp_tour', 'players') }}
)
, no_duplicate_players as (
    -- temporal patch awaiting permanent fix for duplaicate player ids i.e 148670 and 148671
    select *
      from (
            select *
                  ,row_number() over (partition by player_id order by player_id) as num_of_duplicate_players
              from atp_tour_players
      )
     where num_of_duplicate_players = 1
)
, conversion_units as (
    select *
      from {{ ref('ref_conversion_units') }}
)
, renamed as (
    select player_id::int as player_id
          ,name_first||' '||name_last::varchar(100) as player_name
          ,name_first::varchar(50) as first_name
          ,name_last::varchar(50) as last_name
          ,case
              when hand = 'R' then 'Right-handed'
              when hand = 'L' then 'Left-handed'
              when hand = 'A' then 'Ambidextrous'
              when hand = 'U' then 'Unknown'
              else hand
           end::varchar(15) as dominant_hand
          ,dob::date as date_of_birth
          ,{{ to_age('dob') }}::smallint as age
          ,ioc::varchar(3) as country_iso_code
          ,height::smallint as height_in_centimeters
          ,round(height * cu.centimeters_to_inches, 1)::decimal(3,1) as height_in_inches
          ,wikidata_id::varchar(10) as wikidata_id
          ,1 as num_of_players
      from no_duplicate_players p
      left join conversion_units cu on 1 = 1
)
, renamed2 as (
    select player_id
          ,player_name
          ,first_name
          ,last_name
          ,dominant_hand
          ,date_of_birth
          ,age
          ,age||' ('||{{ to_iso_date_us('date_of_birth') }}||')'::varchar(20) as age_incl_date_of_birth
          ,age_incl_date_of_birth
          ,country_iso_code
          ,height_in_centimeters
          ,height_in_inches
          ,replace(CAST(height_in_inches AS VARCHAR), '.', '''')||'" ('||height_in_centimeters||' cm)'::varchar(20) as height
          ,wikidata_id
          ,num_of_players
      from renamed
)
, surrogate_keys as (
    select {{ dbt_utils.surrogate_key(['player_id']) }} as player_sk
          ,{{ to_date_key('date_of_birth') }}::int as date_of_birth_key
          ,{{ to_time_key('date_of_birth') }}::int as time_of_birth_key
          ,{{ to_iso_date('date_of_birth') }} as date_of_birth
          ,*
          exclude(date_of_birth) -- Metabase has a problem with the dob column for some strange reason, so excluding it for now
      from renamed2
)
select *
  from surrogate_keys