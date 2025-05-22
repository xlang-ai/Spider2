{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

/* this test is to make sure there is no fanout from unioning
this is meant as a pulse check since the other models do not
have as predictable of a row count. */
{% if var('apple_store_union_schemas', none) is not none %}
    with source_counts as (
        {% for schema in var('apple_store_union_schemas') %}
            (
                select count(*) as schema_source_count
                from {{ schema }}.app_store_territory_source_type_report
            )
            {% if not loop.last %}
                union all
            {% endif %}
        {% endfor %}
    ),

    source_count as (
        select sum(schema_source_count) as row_count
        from source_counts
    ),

{% else %}
    with source_count as (
        select count(*) as row_count
        from {{ source('apple_store', 'app_store_territory_source_type_report') }}
    ),
{% endif %}

final_count as (
    select count(*) as row_count
    from {{ target.schema }}_apple_store_dev.apple_store__territory_report
)

-- test will return values and fail if the row counts don't match
select *
from source_count
join final_count
    on source_count.row_count != final_count.row_count