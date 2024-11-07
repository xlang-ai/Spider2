{% macro drop_schemas_automation(drop_target_schema=true) %}
    {{ return(adapter.dispatch('drop_schemas_automation', 'fivetran_utils')(drop_target_schema)) }}
{%- endmacro %}

{% macro default__drop_schemas_automation(drop_target_schema=true) %}

{% set fetch_list_sql %}
    {% if target.type not in ('databricks', 'spark') %}
        select schema_name
        from 
        {{ wrap_in_quotes(target.database) }}.INFORMATION_SCHEMA.SCHEMATA
        where lower(schema_name) like '{{ target.schema | lower }}{%- if not drop_target_schema -%}_{%- endif -%}%'
    {% else %}
        SHOW SCHEMAS LIKE '{{ target.schema }}{%- if not drop_target_schema -%}_{%- endif -%}*'
    {% endif %}
{% endset %}

{% set results = run_query(fetch_list_sql) %}

{% if execute %}
    {% set results_list = results.columns[0].values() %}
{% else %}
    {% set results_list = [] %}
{% endif %}

{% for schema_to_drop in results_list %}
    {% do adapter.drop_schema(api.Relation.create(database=target.database, schema=schema_to_drop)) %}
    {{ print('Schema ' ~ schema_to_drop ~ ' successfully dropped from the ' ~ target.database ~ ' database.\n')}}
{% endfor %}

{% endmacro %}