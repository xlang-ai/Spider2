{{
    dbt_activity_schema.dataset(
        ref("example__activity_stream"),
        dbt_activity_schema.activity(dbt_activity_schema.all_ever(), "bought something"),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.first_before(),
                "visited page",
                ["feature_json", "ts"]
            )
        ]
    )
}}
