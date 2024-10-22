{{
    dbt_activity_schema.dataset(
        ref("input__last_in_between"),
        dbt_activity_schema.activity(dbt_activity_schema.all_ever(), "signed up"),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.last_in_between(),
                "visit page",
                ["feature_json", "activity_occurrence", "ts"]
            )
        ]
    )
}}
