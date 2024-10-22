import pandas as pd

def calc_elo_diff(margin: float, game_result: float, home_elo: float, visiting_elo: float, home_adv: float) -> float:
    # just need to make sure i really get a game result that is float (annoying)
    game_result = float(game_result)
    elo_diff = -float((visiting_elo - home_elo - home_adv))
    raw_elo = 20.0 * (( game_result ) - (1.0 / (10.0 ** ( elo_diff / 400.0) + 1.0)))
    if game_result == 1:
       elo_chg =  raw_elo * ((margin + 3)** 0.8 ) / (7.5 + (0.006 * elo_diff ))
    elif game_result == 0:
       elo_chg =  raw_elo * ((margin + 3)** 0.8 ) / (7.5 + (0.006 * -elo_diff ))
    return elo_chg

def model(dbt, sess):
    # get the existing elo ratings for the teams
    home_adv = dbt.config.get("nba_elo_offset",100.0)
    team_ratings = dbt.ref("nba_raw_team_ratings").df()
    original_elo = dict(zip(team_ratings["team_long"], team_ratings["elo_rating"].astype(float)))
    working_elo = original_elo.copy()

    # loop over the historical game data and update the elo ratings as we go
    nba_elo_latest = (dbt.ref("nba_latest_results")
        .project("game_id, visiting_team, home_team, winning_team, margin, game_result")
        .order("game_id")
    )
    nba_elo_latest.execute()
    columns = ["game_id", "visiting_team", "visiting_team_elo_rating", "home_team", "home_team_elo_rating", "winning_team", "elo_change"]
    rows = []
    for (game_id, vteam, hteam, winner, margin, game_result) in nba_elo_latest.fetchall():
        helo, velo = working_elo[hteam], working_elo[vteam]
        elo_change =  calc_elo_diff(margin, game_result, helo, velo, home_adv)
        rows.append((game_id, vteam, velo, hteam, helo, winner, elo_change))
        working_elo[hteam] -= elo_change
        working_elo[vteam] += elo_change

    return pd.DataFrame(columns=columns, data=rows)