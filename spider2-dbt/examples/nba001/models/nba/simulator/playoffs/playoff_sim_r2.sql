with
    cte_playoff_sim as ({{ playoff_sim("playoffs_r2", "playoff_sim_r1") }})

    {{ playoff_sim_end("cte_playoff_sim") }}
