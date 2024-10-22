{% macro add_dbt_source_relation() %}

{% if var('union_schemas', none) or var('union_databases', none) %}
, _dbt_source_relation
{% endif %}

{% endmacro %}