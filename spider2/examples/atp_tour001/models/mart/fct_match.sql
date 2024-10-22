with matches as (
	select *
	  from {{ ref('stg_atp_tour__matches') }}
)
, players as (
	select *
	  from {{ ref('stg_atp_tour__players') }}
)
, ref_unknown_record as (
	select *
	  from {{ ref('ref_unknown_values') }}
)
, match as (
	select coalesce(cast(tournament_sk as varchar), cast(u.unknown_key as varchar)) as dim_tournament_key
		  ,coalesce(cast(tournament_date_key as varchar), cast(u.unknown_key as varchar)) as dim_tournament_date_key
		  ,coalesce(cast(player_winner_key as varchar), cast(u.unknown_key as varchar)) as dim_player_winner_key
		  ,coalesce(cast(player_loser_key as varchar), cast(u.unknown_key as varchar)) as dim_player_loser_key
		  ,coalesce(cast(w.date_of_birth_key as varchar), cast(u.unknown_key as varchar)) as dim_date_winner_date_of_birth_key
		  ,coalesce(cast(l.date_of_birth_key as varchar), cast(u.unknown_key as varchar)) as dim_date_loser_date_of_birth_key
		  ,coalesce(cast(score as varchar), '0') as score
		  ,coalesce(best_of, 0) as best_of
		  ,coalesce(cast(best_of_labeled as varchar), u.unknown_text) as best_of_labeled
		  ,coalesce(cast(round as varchar), '0') as round
		  ,coalesce(minutes, 0) as minutes
		  ,1 as num_of_matches
		  ,coalesce(cast(winner_seed as varchar), '0') as winner_seed
		  ,coalesce(cast(winner_entry as varchar), u.unknown_text) as winner_entry
		  ,coalesce(winner_height_cm, 0) as winner_height_cm
		  ,coalesce(winner_age, 0) as winner_age
		  ,coalesce(winner_num_of_aces, 0) as winner_num_of_aces
		  ,coalesce(winner_num_of_double_faults, 0) as winner_num_of_double_faults
		  ,coalesce(winner_num_of_serve_pts, 0) as winner_num_of_serve_pts
		  ,coalesce(winner_num_of_1st_serves_made, 0) as winner_num_of_1st_serves_made
		  ,coalesce(winner_num_of_1st_serve_pts_won, 0) as winner_num_of_1st_serve_pts_won
		  ,coalesce(winner_num_of_2nd_serve_pts_won, 0) as winner_num_of_2nd_serve_pts_won
		  ,coalesce(winner_num_of_serve_games, 0) as winner_num_of_serve_games
		  ,coalesce(winner_num_of_break_pts_saved, 0) as winner_num_of_break_pts_saved
		  ,coalesce(winner_num_of_break_pts_faced, 0) as winner_num_of_break_pts_faced
		  ,coalesce(winner_rank, 0) as winner_rank
		  ,coalesce(winner_rank_pts, 0) as winner_rank_pts
		  ,coalesce(cast(loser_seed as varchar), '0') as loser_seed
		  ,coalesce(cast(loser_entry as varchar), u.unknown_text) as loser_entry
		  ,coalesce(loser_height_cm, 0) as loser_height_cm
		  ,coalesce(loser_age, 0) as loser_age
		  ,coalesce(loser_num_of_aces, 0) as loser_num_of_aces
		  ,coalesce(loser_num_of_double_faults, 0) as loser_num_of_double_faults
		  ,coalesce(loser_num_of_serve_pts, 0) as loser_num_of_serve_pts
		  ,coalesce(loser_num_of_1st_serves_made, 0) as loser_num_of_1st_serves_made
		  ,coalesce(loser_num_of_1st_serve_pts_won, 0) as loser_num_of_1st_serve_pts_won
		  ,coalesce(loser_num_of_2nd_serve_pts_won, 0) as loser_num_of_2nd_serve_pts_won
		  ,coalesce(loser_num_of_serve_games, 0) as loser_num_of_serve_games
		  ,coalesce(loser_num_of_break_pts_saved, 0) as loser_num_of_break_pts_saved
		  ,coalesce(loser_num_of_break_pts_faced, 0) as loser_num_of_break_pts_faced
		  ,coalesce(loser_rank, 0) as loser_rank
		  ,coalesce(loser_rank_pts, 0) as loser_rank_pts
          ,coalesce(total_num_of_aces, 0) as total_num_of_aces
          ,coalesce(total_num_of_double_faults, 0) as total_num_of_double_faults
          ,coalesce(total_num_of_serve_pts, 0) as total_num_of_serve_pts
          ,coalesce(total_num_of_1st_serves_made, 0) as total_num_of_1st_serves_made
          ,coalesce(total_num_of_1st_serve_pts_won, 0) as total_num_of_1st_serve_pts_won
          ,coalesce(total_num_of_2nd_serve_pts_won, 0) as total_num_of_2nd_serve_pts_won
          ,coalesce(total_num_of_serve_games, 0) as total_num_of_serve_games
          ,coalesce(total_num_of_break_pts_saved, 0) as total_num_of_break_pts_saved
          ,coalesce(total_num_of_break_pts_faced, 0) as total_num_of_break_pts_faced
		  ,coalesce(age_difference, 0) as age_difference
	  from matches m
	  left join ref_unknown_record u on 1 = 1
	  left join players w on m.winner_id = w.player_id
	  left join players l on m.loser_id = l.player_id
)
select *
  from match
