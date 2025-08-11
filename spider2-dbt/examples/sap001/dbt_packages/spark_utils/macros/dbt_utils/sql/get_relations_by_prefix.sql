{% macro spark__get_relations_by_pattern(schema_pattern, table_pattern, exclude='', database=target.database) %}

    {%- call statement('get_tables', fetch_result=True) %}

        show table extended in {{ schema_pattern }} like '{{ table_pattern }}'

    {%- endcall -%}

    {%- set table_list = load_result('get_tables') -%}

    {%- if table_list and table_list['table'] -%}
    {%- set tbl_relations = [] -%}
    {%- for row in table_list['table'] -%}
        {%- set tbl_relation = api.Relation.create(
            database=None,
            schema=row[0],
            identifier=row[1],
            type=('view' if 'Type: VIEW' in row[3] else 'table')
        ) -%}
        {%- do tbl_relations.append(tbl_relation) -%}
    {%- endfor -%}

    {{ return(tbl_relations) }}
    {%- else -%}
    {{ return([]) }}
    {%- endif -%}

{% endmacro %}

{% macro spark__get_relations_by_prefix(schema_pattern, table_pattern, exclude='', database=target.database) %}
    {% set table_pattern = table_pattern ~ '*' %}
    {{ return(spark_utils.spark__get_relations_by_pattern(schema_pattern, table_pattern, exclude='', database=target.database)) }}
{% endmacro %}

{% macro spark__get_tables_by_pattern(schema_pattern, table_pattern, exclude='', database=target.database) %}
    {{ return(spark_utils.spark__get_relations_by_pattern(schema_pattern, table_pattern, exclude='', database=target.database)) }}
{% endmacro %}

{% macro spark__get_tables_by_prefix(schema_pattern, table_pattern, exclude='', database=target.database) %}
    {{ return(spark_utils.spark__get_relations_by_prefix(schema_pattern, table_pattern, exclude='', database=target.database)) }}
{% endmacro %}
