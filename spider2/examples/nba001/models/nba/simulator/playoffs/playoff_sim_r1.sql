with
    cte_playoff_sim as ({{ playoff_sim("playoffs_r1", "initialize_seeding") }})

    {{ playoff_sim_end("cte_playoff_sim") }}
