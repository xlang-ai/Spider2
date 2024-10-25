{{
    dbt_activity_schema.dataset(
        ref("input__first_in_between"),
        dbt_activity_schema.activity(
            dbt_activity_schema.all_ever(),
            "signed up"
        ),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.first_in_between(),
                "bought something",
                ["feature_json", "ts", "revenue_impact"]
            )
        ]
    )
}}
