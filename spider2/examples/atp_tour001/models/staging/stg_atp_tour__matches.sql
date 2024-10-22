{{ config(
    tags=["staging"]
  )
}}

with atp_tour_matches as (
    select *
      from {{ source('atp_tour', 'matches') }}
)
, renamed as (
    select tourney_id::varchar(50) as tournament_id
          ,tourney_name::varchar(100) as tournament_name
          ,case
              when tourney_level = 'A' then 'Other tour-level events'
              when tourney_level = 'D' then 'Davis Cup'
              when tourney_level = 'F' then 'Tour finals'
              when tourney_level = 'G' then 'Grand Slams'
              when tourney_level = 'M' then 'Masters 1000s'
           end::varchar(25) as tournament_level
          ,tourney_date::date as tournament_date
          ,surface::varchar(10) as surface
          ,draw_size::smallint as draw_size
          ,match_num::smallint as match_id
          ,score::varchar(50) as score
          ,best_of::tinyint as best_of
          ,('Best of '||best_of)::varchar(10) as best_of_labeled
          ,case
                -- when round = 'BR' then ''
                -- when round = 'ER' then ''
                when round = 'F' then 'Final'
                when round = 'QF' then 'Quarterfinal'
                when round = 'R16' then 'Round of 16'
                when round = 'R32' then 'Round of 32'
                when round = 'R64' then 'Round of 64'
                when round = 'R128' then 'Round of 128'
                when round = 'RR' then 'Round robin'
                when round = 'SF' then 'Semifinal'
                else round
           end::varchar(4) as round
          ,minutes::smallint as minutes
          ,winner_id::int as winner_id
          ,winner_seed::tinyint as winner_seed
          ,case
              when winner_entry = 'WC' then 'Wild card'
              when winner_entry = 'Q' then 'Qualifier'
              when winner_entry = 'LL' then 'Lucky loser'
              when winner_entry = 'PR' then 'Protected ranking'
              when winner_entry = 'ITF' then 'ITF entry'
              else winner_entry
           end::varchar(20) as winner_entry
          ,winner_name::varchar(100) as winner_name
          ,case
              when winner_hand = 'R' then 'Right-handed'
              when winner_hand = 'L' then 'Left-handed'
              when winner_hand = 'A' then 'Ambidextrous'
              when winner_hand = 'U' then 'Unknown'
              else winner_hand
           end::varchar(15) as winner_dominant_hand
          ,winner_ht::smallint as winner_height_cm
          ,winner_ioc::varchar(3) as winner_country_iso_code
          ,winner_age::tinyint as winner_age
          ,w_ace::tinyint as winner_num_of_aces
          ,w_df::smallint as winner_num_of_double_faults
          ,w_svpt::smallint as winner_num_of_serve_pts
          ,w_1stin::smallint as winner_num_of_1st_serves_made
          ,w_1stwon::smallint as winner_num_of_1st_serve_pts_won
          ,w_2ndwon::smallint as winner_num_of_2nd_serve_pts_won
          ,w_svgms::smallint as winner_num_of_serve_games
          ,w_bpsaved::smallint as winner_num_of_break_pts_saved
          ,w_bpfaced::smallint as winner_num_of_break_pts_faced
          ,winner_rank::smallint as winner_rank
          ,winner_rank_points::smallint as winner_rank_pts
          ,loser_id::int as loser_id
          ,loser_seed::tinyint as loser_seed
          ,case
              when loser_entry = 'WC' then 'Wild card'
              when loser_entry = 'Q' then 'Qualifier'
              when loser_entry = 'LL' then 'Lucky loser'
              when loser_entry = 'PR' then 'Protected ranking'
              when loser_entry = 'ITF' then 'ITF entry'
              else loser_entry
           end::varchar(20) as loser_entry
          ,loser_name::varchar(100) as loser_name
          ,case
              when loser_hand = 'R' then 'Right-handed'
              when loser_hand = 'L' then 'Left-handed'
              when loser_hand = 'A' then 'Ambidextrous'
              when loser_hand = 'U' then 'Unknown'
              else loser_hand
           end::varchar(15) as loser_dominant_hand
          ,loser_ht::smallint as loser_height_cm
          ,loser_ioc::varchar(3) as loser_country_iso_code
          ,loser_age::tinyint as loser_age
          ,l_ace::tinyint as loser_num_of_aces
          ,l_df::smallint as loser_num_of_double_faults
          ,l_svpt::smallint as loser_num_of_serve_pts
          ,l_1stin::smallint as loser_num_of_1st_serves_made
          ,l_1stwon::smallint as loser_num_of_1st_serve_pts_won
          ,l_2ndwon::smallint as loser_num_of_2nd_serve_pts_won
          ,l_svgms::smallint as loser_num_of_serve_games
          ,l_bpsaved::smallint as loser_num_of_break_pts_saved
          ,l_bpfaced::smallint as loser_num_of_break_pts_faced
          ,loser_rank::smallint as loser_rank
          ,loser_rank_points::smallint as loser_rank_pts
          ,w_ace::int + l_ace::int as total_num_of_aces
          ,w_df::int + l_df::int as total_num_of_double_faults
          ,w_svpt::int + l_svpt::int as total_num_of_serve_pts
          ,w_1stin::int + l_1stin::int as total_num_of_1st_serves_made
          ,w_1stwon::int + l_1stwon::int as total_num_of_1st_serve_pts_won
          ,w_2ndwon::int + l_2ndwon::int as total_num_of_2nd_serve_pts_won
          ,w_svgms::int + l_svgms::int as total_num_of_serve_games
          ,w_bpsaved::int + l_bpsaved::int as total_num_of_break_pts_saved
          ,w_bpfaced::int + l_bpfaced::int as total_num_of_break_pts_faced
          ,abs(winner_age::tinyint - loser_age::tinyint) as age_difference
      from atp_tour_matches
)
, surrogate_keys as (
    select {{ dbt_utils.surrogate_key(['tournament_id', 'tournament_date']) }} as tournament_sk
          ,{{ dbt_utils.surrogate_key(['tournament_id', 'match_id']) }} as match_sk
          ,{{ to_date_key('tournament_date') }}::int as tournament_date_key
          ,{{ dbt_utils.surrogate_key(['winner_id']) }} as player_winner_key
          ,{{ dbt_utils.surrogate_key(['loser_id']) }} as player_loser_key
          ,*
      from renamed
)
select *
  from surrogate_keys