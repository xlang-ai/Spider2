{% set join_condition %}
json_extract({{ dbt_activity_schema.primary() }}.feature_json, 'type')
= json_extract({{ dbt_activity_schema.appended() }}.feature_json, 'type')
{% endset %}

{{
    dbt_activity_schema.dataset(
        ref("input__first_in_between"),
        dbt_activity_schema.activity(
            dbt_activity_schema.all_ever(),
            "signed up",
            [
                "activity_id",
                "entity_uuid",
                "ts",
                "revenue_impact",
                "feature_json"
            ]
        ),
        [
            dbt_activity_schema.activity(
                dbt_activity_schema.first_in_between(),
                "visit page",
                [
                    "feature_json",
                    "activity_occurrence",
                    "ts"
                ],
                additional_join_condition=join_condition
            ),
            dbt_activity_schema.activity(
                dbt_activity_schema.first_in_between(),
                "bought something",
                [
                    "revenue_impact",
                    "activity_id",
                    "ts"
                ]
            )
        ]
    )
}}
