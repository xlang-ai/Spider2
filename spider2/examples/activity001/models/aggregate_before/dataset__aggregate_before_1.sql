{{
    dbt_activity_schema.dataset(
        ref("input__aggregate_before"),
        dbt_activity_schema.activity(dbt_activity_schema.all_ever(), "bought something"),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.aggregate_before(),
                "visit page",
                ["activity_id"]
            ),
            dbt_activity_schema.activity(
                dbt_activity_schema.aggregate_before(),
                "added to cart",
                ["activity_id"]
            )
        ]
    )
}}
