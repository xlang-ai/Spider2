{{
    dbt_activity_schema.dataset(
        ref("example__activity_stream"),
        dbt_activity_schema.activity(dbt_activity_schema.last_ever(),"visited page"),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.last_ever(),
                "bought something",
                ["feature_json", "ts"]
            )
        ]
    )
}}
