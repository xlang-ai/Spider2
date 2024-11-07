{{
    dbt_activity_schema.dataset(
        ref("input__last_after"),
        dbt_activity_schema.activity(dbt_activity_schema.nth_ever(1), "signed up"),
        [
            dbt_activity_schema.activity(dbt_activity_schema.last_after(), "visit page")
        ]
    )
}}
