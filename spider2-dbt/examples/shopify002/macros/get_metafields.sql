{% macro get_metafields(source_object, reference_value, lookup_object="stg_shopify__metafield", key_field="metafield_reference", key_value="value", reference_field="owner_resource") %}

{% set pivot_fields = dbt_utils.get_column_values(table=ref(lookup_object), column=key_field, where="lower(" ~ reference_field ~ ") = lower('" ~ reference_value ~ "')") %}

{% set source_columns = adapter.get_columns_in_relation(ref(source_object)) %}
{% set source_column_count = source_columns | length %}

with source_table as (
    select *
    from {{ ref(source_object) }}
)

{% if pivot_fields is not none %},
lookup_object as (
    select 
        *,
        {{ dbt_utils.pivot(
                column=key_field, 
                values=pivot_fields, 
                agg='', 
                then_value=key_value, 
                else_value="null",
                quote_identifiers=false
                ) 
        }}
    from {{ ref(lookup_object) }}
    where is_most_recent_record
),

final as (
    select
        {% for column in source_columns %}
            source_table.{{ column.name }}{% if not loop.last %},{% endif %}
        {% endfor %}
        {% for fields in pivot_fields %}
            , max(lookup_object.{{ dbt_utils.slugify(fields) }}) as metafield_{{ dbt_utils.slugify(fields) }}
        {% endfor %}
    from source_table
    left join lookup_object 
        on lookup_object.{{ reference_field }}_id = source_table.{{ reference_value }}_id
        and lookup_object.{{ reference_field }} = '{{ reference_value }}'
    {{ dbt_utils.group_by(source_column_count) }}
)

select *
from final
{% else %}

select *
from source_table
{% endif %}
{% endmacro %}