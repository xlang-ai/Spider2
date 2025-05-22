{% macro add_pass_through_columns(base_columns, pass_through_var) %}

  {% if pass_through_var %}

    {% for column in pass_through_var %}

    {% if column is mapping %}

      {% if column.alias %}

        {% do base_columns.append({ "name": column.name, "alias": column.alias, "datatype": column.datatype if column.datatype else dbt.type_string()}) %}

      {% else %}

        {% do base_columns.append({ "name": column.name, "datatype": column.datatype if column.datatype else dbt.type_string()}) %}
        
      {% endif %}

    {% else %}

      {% do base_columns.append({ "name": column, "datatype": dbt.type_string()}) %}

    {% endif %}

    {% endfor %}

  {% endif %}

{% endmacro %}