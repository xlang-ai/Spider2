with
    cte_wins as (
        select
            s.scenario_id,
            s.winning_team,
            case
                when s.winning_team = s.home_team then s.home_conf else s.visiting_conf
            end as conf,
            /*    CASE
            WHEN S.winning_team = S.home_team THEN S.home_team_elo_rating
            ELSE S.visiting_team_elo_rating
        END AS elo_rating, */
            count(*) as wins
        from "nba"."main"."reg_season_simulator" s
        group by all
    ),

    cte_ranked_wins as (
        select
            *,
            -- no tiebreaker, so however row number handles order ties will need to be
            -- dealt with
            row_number() over (
                partition by scenario_id, conf order by wins desc, winning_team desc
            ) as season_rank
        from cte_wins

    ),

    cte_made_playoffs as (
        select
            *,
            case when season_rank <= 10 then 1 else 0 end as made_playoffs,
            case when season_rank between 7 and 10 then 1 else 0 end as made_play_in,
            conf || '-' || season_rank::text as seed
        from cte_ranked_wins
    )

select mp.*, le.elo_rating, 0 as sim_start_game_id
from cte_made_playoffs mp
left join "nba"."main"."nba_latest_elo" le on le.team = mp.winning_team