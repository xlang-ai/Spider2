{{
    dbt_activity_schema.dataset(
        ref("input__aggregate_in_between"),
        dbt_activity_schema.activity(dbt_activity_schema.all_ever(), "visit page"),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.aggregate_in_between(),
                "added to cart",
                ["activity_id"]
            ),
            dbt_activity_schema.activity(
                dbt_activity_schema.aggregate_in_between(dbt_activity_schema.sum),
                "bought something",
                ["revenue_impact"]
            ),
            dbt_activity_schema.activity(
                dbt_activity_schema.aggregate_in_between(),
                "bought something",
                ["activity_id"]
            )
        ]
    )
}}
