
  
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


# This part is user provided model code
# you will need to copy the next section to run the code
# COMMAND ----------
# this part is dbt logic for get ref work, do not modify

def ref(*args, **kwargs):
    refs = {"nba_latest_results": "\"nba\".\"main\".\"nba_latest_results\"", "nba_raw_team_ratings": "\"nba\".\"main\".\"nba_raw_team_ratings\""}
    key = '.'.join(args)
    version = kwargs.get("v") or kwargs.get("version")
    if version:
        key += f".v{version}"
    dbt_load_df_function = kwargs.get("dbt_load_df_function")
    return dbt_load_df_function(refs[key])


def source(*args, dbt_load_df_function):
    sources = {}
    key = '.'.join(args)
    return dbt_load_df_function(sources[key])


config_dict = {'nba_elo_offset': 100.0}


class config:
    def __init__(self, *args, **kwargs):
        pass

    @staticmethod
    def get(key, default=None):
        return config_dict.get(key, default)

class this:
    """dbt.this() or dbt.this.identifier"""
    database = "nba"
    schema = "main"
    identifier = "nba_elo_rollforward"
    
    def __repr__(self):
        return '"nba"."main"."nba_elo_rollforward"'


class dbtObj:
    def __init__(self, load_df_function) -> None:
        self.source = lambda *args: source(*args, dbt_load_df_function=load_df_function)
        self.ref = lambda *args, **kwargs: ref(*args, **kwargs, dbt_load_df_function=load_df_function)
        self.config = config
        self.this = this()
        self.is_incremental = False

# COMMAND ----------




def materialize(df, con):
    try:
        import pyarrow
        pyarrow_available = True
    except ImportError:
        pyarrow_available = False
    finally:
        if pyarrow_available and isinstance(df, pyarrow.Table):
            # https://github.com/duckdb/duckdb/issues/6584
            import pyarrow.dataset
    con.execute('create table "nba"."main"."nba_elo_rollforward__dbt_tmp" as select * from df')

  