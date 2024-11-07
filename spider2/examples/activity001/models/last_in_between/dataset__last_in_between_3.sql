{{
    dbt_activity_schema.dataset(
        ref("input__last_in_between"),
        dbt_activity_schema.activity(dbt_activity_schema.all_ever(), "visit page"),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.last_in_between(),
                "bought something",
                ["activity_id", "revenue_impact"]
            )
        ]
    )
}}
