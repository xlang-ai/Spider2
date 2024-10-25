{{
    dbt_activity_schema.dataset(
        ref("input__nth_ever"),
        dbt_activity_schema.activity(
            dbt_activity_schema.nth_ever(2),
            "visit page",
            ["activity_occurrence"]
        ),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.nth_ever(3),
                "visit page",
                ["activity_occurrence"]
            ),
            dbt_activity_schema.activity(
                dbt_activity_schema.nth_ever(4),
                "visit page",
                ["activity_occurrence"]
            ),
            dbt_activity_schema.activity(
                dbt_activity_schema.nth_ever(5),
                "visit page",
                ["activity_occurrence"]
            ),
        ]
    )
}}
