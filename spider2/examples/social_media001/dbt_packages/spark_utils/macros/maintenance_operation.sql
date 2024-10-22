{% macro get_tables(table_regex_pattern='.*') %}

  {% set tables = [] %}
  {% for database in spark__list_schemas('not_used') %}
    {% for table in spark__list_relations_without_caching(database[0]) %}
      {% set db_tablename = database[0] ~ "." ~ table[1] %}
      {% set is_match = modules.re.match(table_regex_pattern, db_tablename) %}
      {% if is_match %}
        {% call statement('table_detail', fetch_result=True) -%}
          describe extended {{ db_tablename }}
        {% endcall %}

        {% set table_type = load_result('table_detail').table|reverse|selectattr(0, 'in', ('type', 'TYPE', 'Type'))|first %}
        {% if table_type[1]|lower != 'view' %}
          {{ tables.append(db_tablename) }}
        {% endif %}
      {% endif %}
    {% endfor %}
  {% endfor %}
  {{ return(tables) }}

{% endmacro %}

{% macro get_delta_tables(table_regex_pattern='.*') %}

  {% set delta_tables = [] %}
  {% for db_tablename in get_tables(table_regex_pattern) %}
    {% call statement('table_detail', fetch_result=True) -%}
      describe extended {{ db_tablename }}
    {% endcall %}

    {% set table_type = load_result('table_detail').table|reverse|selectattr(0, 'in', ('provider', 'PROVIDER', 'Provider'))|first %}
    {% if table_type[1]|lower == 'delta' %}
      {{ delta_tables.append(db_tablename) }}
    {% endif %}
  {% endfor %}
  {{ return(delta_tables) }}

{% endmacro %}

{% macro get_statistic_columns(table) %}

  {% call statement('input_columns', fetch_result=True) %}
    SHOW COLUMNS IN {{ table }}
  {% endcall %}
  {% set input_columns = load_result('input_columns').table %}

  {% set output_columns = [] %}
  {% for column in input_columns %}
    {% call statement('column_information', fetch_result=True) %}
      DESCRIBE TABLE {{ table }} `{{ column[0] }}`
    {% endcall %}
    {% if not load_result('column_information').table[1][1].startswith('struct') and not load_result('column_information').table[1][1].startswith('array')  %}
      {{ output_columns.append('`' ~ column[0] ~ '`') }}
    {% endif %}
  {% endfor %}
  {{ return(output_columns) }}

{% endmacro %}

{% macro spark_optimize_delta_tables(table_regex_pattern='.*') %}

  {% for table in get_delta_tables(table_regex_pattern) %}
    {% set start=modules.datetime.datetime.now() %}
    {% set message_prefix=loop.index ~ " of " ~ loop.length %}
    {{ dbt_utils.log_info(message_prefix ~ " Optimizing " ~ table) }}
    {% do run_query("optimize " ~ table) %}
    {% set end=modules.datetime.datetime.now() %}
    {% set total_seconds = (end - start).total_seconds() | round(2)  %}
    {{ dbt_utils.log_info(message_prefix ~ " Finished " ~ table ~ " in " ~ total_seconds ~ "s") }}
  {% endfor %}

{% endmacro %}

{% macro spark_vacuum_delta_tables(table_regex_pattern='.*') %}

  {% for table in get_delta_tables(table_regex_pattern) %}
    {% set start=modules.datetime.datetime.now() %}
    {% set message_prefix=loop.index ~ " of " ~ loop.length %}
    {{ dbt_utils.log_info(message_prefix ~ " Vacuuming " ~ table) }}
    {% do run_query("vacuum " ~ table) %}
    {% set end=modules.datetime.datetime.now() %}
    {% set total_seconds = (end - start).total_seconds() | round(2)  %}
    {{ dbt_utils.log_info(message_prefix ~ " Finished " ~ table ~ " in " ~ total_seconds ~ "s") }}
  {% endfor %}

{% endmacro %}

{% macro spark_analyze_tables(table_regex_pattern='.*') %}

  {% for table in get_tables(table_regex_pattern) %}
    {% set start=modules.datetime.datetime.now() %}
    {% set columns = get_statistic_columns(table) | join(',') %}
    {% set message_prefix=loop.index ~ " of " ~ loop.length %}
    {{ dbt_utils.log_info(message_prefix ~ " Analyzing " ~ table) }}
    {% if columns != '' %}
      {% do run_query("analyze table " ~ table ~ " compute statistics for columns " ~ columns) %}
    {% endif %}
    {% set end=modules.datetime.datetime.now() %}
    {% set total_seconds = (end - start).total_seconds() | round(2)  %}
    {{ dbt_utils.log_info(message_prefix ~ " Finished " ~ table ~ " in " ~ total_seconds ~ "s") }}
  {% endfor %}

{% endmacro %}
