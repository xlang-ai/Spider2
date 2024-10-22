{{
    dbt_activity_schema.dataset(
        ref("input__first_after"),
        dbt_activity_schema.activity(
            dbt_activity_schema.all_ever(),
            "visit page"
        ),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.first_after(),
                "bought something",
                ["feature_json", "ts"]
            )
        ]
    )
}}
