with
    cte_playoff_sim as ({{ playoff_sim("playoffs_r4", "playoff_sim_r3") }})

    {{ playoff_sim_end("cte_playoff_sim") }}
