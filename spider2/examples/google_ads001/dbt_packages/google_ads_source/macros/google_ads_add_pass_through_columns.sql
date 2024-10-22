{# Backwards compatible version of fivetran_utils.add_pass_through_columns #}

{% macro google_ads_add_pass_through_columns(base_columns, pass_through_fields, except_fields=[]) %}

{% if pass_through_fields %}
    {% for column in pass_through_fields %}

        {% if column is mapping %}
        {% set col_name = column.alias|default(column.name)|lower %}
        
            {% if col_name not in except_fields %}
                {% if column.alias %}
                    {% do base_columns.append({ "name": column.name, "alias": column.alias, "datatype": column.datatype if column.datatype else dbt.type_string()}) %}
                {% else %}
                    {% do base_columns.append({ "name": column.name, "datatype": column.datatype if column.datatype else dbt.type_string()}) %}
                {% endif %}
            {% endif %}

        {% else %}
            {% if column|lower not in except_fields %}
                {% do base_columns.append({ "name": column, "datatype": dbt.type_string()}) %}
            {% endif %}
        {% endif %}

    {% endfor %}
{% endif %}

{% endmacro %}