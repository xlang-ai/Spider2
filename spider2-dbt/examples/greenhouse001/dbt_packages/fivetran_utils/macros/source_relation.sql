{% macro source_relation(union_schema_variable='union_schemas', union_database_variable='union_databases') -%}

{{ adapter.dispatch('source_relation', 'fivetran_utils') (union_schema_variable, union_database_variable) }}

{%- endmacro %}

{% macro default__source_relation(union_schema_variable, union_database_variable) %}

{% if var(union_schema_variable, none)  %}
, case
    {% for schema in var(union_schema_variable) %}
    when lower(replace(replace(_dbt_source_relation,'"',''),'`','')) like '%.{{ schema|lower }}.%' then '{{ schema|lower }}'
    {% endfor %}
  end as source_relation
{% elif var(union_database_variable, none) %}
, case
    {% for database in var(union_database_variable) %}
    when lower(replace(replace(_dbt_source_relation,'"',''),'`','')) like '%{{ database|lower }}.%' then '{{ database|lower }}'
    {% endfor %}
  end as source_relation
{% else %}
, cast('' as {{ dbt.type_string() }}) as source_relation
{% endif %}

{% endmacro %}
