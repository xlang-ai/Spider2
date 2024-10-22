{{
    dbt_activity_schema.dataset(
        ref("example__activity_stream"),
        dbt_activity_schema.activity(
            dbt_activity_schema.all_ever(),
            "visited page",
            var("dbt_activity_schema").get("included_columns") + ["visited_page"]
        ),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.first_ever(),
                "signed up",
                ["feature_json", "ts", "signed_up"]
            )
        ]
    )
}}
