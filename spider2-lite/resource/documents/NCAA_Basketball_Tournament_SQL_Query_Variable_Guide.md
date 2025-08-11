#### NCAA Basketball Tournament SQL Query Variable Guide



This document provides a detailed explanation of the variables used and extracted in the SQL query focused on NCAA basketball tournament game outcomes. The purpose of this guide is to share insights into each variable's meaning and describe how they are derived within the query.



\## Variables and Their Meanings



\### Features and Labels



1. **`season`**:

   \- Represents the year of the NCAA tournament season being analyzed.

   \- **Source**: Directly selected from the datasets.



2. **`label`**:

   \- Indicates the outcome of the game for the team in focus: either "win" or "loss".

   \- **Source**: Manually assigned in the `SELECT` statement, depending on whether the team won or lost.



3. **`seed`**:

   \- The seed ranking of the team associated with the outcome.

   \- **Source**: Selected from `win_seed` or `lose_seed` as applicable from the dataset.



4. **`school_ncaa`**:

   \- The NCAA school or team involved in the game.

   \- **Source**: Selected from `win_school_ncaa` or `lose_school_ncaa` based on the context of the row (win/loss).



5. **`opponent_seed`**:

   \- The seed ranking of the opposing team.

   \- **Source**: Selected oppositely to `seed`.



6. **`opponent_school_ncaa`**:

   \- The opposing NCAA school or team.

   \- **Source**: Selected oppositely to `school_ncaa`.



\### Team Metrics



\#### New Pace Metrics



7. **`pace_rank`**:

   \- Reflects the team's rank in pace, measuring possessions over time.

   \- **Source**: Joined from `team.pace_rank` in the `feature_engineering` dataset.



8. **`poss_40min`**:

   \- The average number of possessions over a 40-minute game.

   \- **Source**: Joined from `team.poss_40min`.



9. **`pace_rating`**:

   \- Rating of the team's pace performance.

   \- **Source**: Joined from `team.pace_rating`.



\#### New Efficiency Metrics



10. **`efficiency_rank`**:

​    \- Rank based on scoring efficiency over time.

​    \- **Source**: Joined from `team.efficiency_rank`.



11. **`pts_100poss`**:

​    \- Points scored per 100 possessions.

​    \- **Source**: Joined from `team.pts_100poss`.



12. **`efficiency_rating`**:

​    \- Overall efficiency rating.

​    \- **Source**: Joined from `team.efficiency_rating`.



\### Opponent Metrics



13. **`opp_pace_rank`**, **`opp_poss_40min`**, **`opp_pace_rating`**, **`opp_efficiency_rank`**, **`opp_pts_100poss`**, **`opp_efficiency_rating`**:

​    \- Corresponding pace and efficiency metrics for the opponent team.

​    \- **Source**: Joined parallel fields from `opp` (opposing team's data) in the `feature_engineering` dataset.



\### Feature Engineering: Differences



14. **`pace_rank_diff`**, **`pace_stat_diff`**, **`pace_rating_diff`**, **`eff_rank_diff`**, **`eff_stat_diff`**, **`eff_rating_diff`**:

​    \- Differences calculated between the metrics of the opposing team and the team in focus.

​    \- **Source**: Derived by subtracting the team's metric from the opponent's metric using calculated fields in the `SELECT` statement.