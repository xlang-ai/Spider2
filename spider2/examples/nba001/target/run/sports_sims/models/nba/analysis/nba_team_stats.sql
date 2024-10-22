
  
    
    

    create  table
      "nba"."main"."nba_team_stats__dbt_tmp"
  
    as (
      

with
    cte_games as (
        select
            team1,
            team2,
            score1,
            score2,
            playoff,
            case when score1 > score2 then team1 else team2 end as winner,
            case when score1 < score2 then team1 else team2 end as loser,
            case when team1 = t.team then elo1_pre else elo2_pre end as elo,
            case when team1 = t.team then score1 else score2 end as pf,
            case when team1 = t.team then score2 else score1 end as pa,
            t.team || ':' || t.season as key,
            t.team,
            t.season
        from "nba"."main"."nba_elo_history" h
        left join
            "nba"."main"."nba_season_teams" t
            on (t.team = h.team1 or t.team = h.team2)
            and h.season = t.season
    )
select
    key,
    count(*) as ct,
    count(*) filter (where winner = team and playoff = 'r') as wins,
    - count(*) filter (where loser = team and playoff = 'r') as losses,
    count(*) filter (
        where winner = team and team1 = team and playoff = 'r'
    ) as home_wins, - count(*) filter (
        where loser = team and team1 = team and playoff = 'r'
    ) as home_losses,
    count(*) filter (
        where winner = team and team2 = team and playoff = 'r'
    ) as away_wins, - count(*) filter (
        where loser = team and team2 = team and playoff = 'r'
    ) as away_losses,
    count(*) filter (where winner = team and playoff <> 'r') as playoff_wins,
    - count(*) filter (where loser = team and playoff <> 'r') as playoff_losses,
    avg(pf) as pf,
    avg(- pa) as pa,
    avg(pf) - avg(pa) as margin,
    min(elo) as min_elo,
    avg(elo) as avg_elo,
    max(elo) as max_elo,
    team as team,
    season as season
from cte_games
group by all
    );
  
  