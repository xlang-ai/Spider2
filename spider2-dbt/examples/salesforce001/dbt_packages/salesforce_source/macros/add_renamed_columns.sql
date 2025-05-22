{% macro add_renamed_columns(column_list) %}
{# This macro determines the original names for each column and adds them to the list generated within each `get_*_columns` macro. By default, this macro processes column names by removing underscores and capitalizing each part that follows an underscore. This ensures all necessary columns are available for use in the `coalesce_rename` macro. Additionally, this macro tags each column with its renamed version to maintain tracking. #}

{%- set renamed_columns = [] %}

{%- for col in column_list %}

    {%- set original_column_name = col.name %}

    {%- if 'fivetran' not in original_column_name %}
        {# Use renamed_column_name value if it provided in the get_columns macro #}
        {%- set renamed_column_name = col.renamed_column_name | default(original_column_name.split('_') | map('capitalize') | join('')) %}

        {# Add an entry to the list of renames to populate the filled columns if the rename is different #}
        {%- do renamed_columns.append({"name": renamed_column_name, "datatype": col.datatype, "is_rename": true}) if renamed_column_name|lower != original_column_name|lower %}

        {# Update the original column with the renamed column name for use later. #}
        {%- set col = col.update({ "renamed_column_name": renamed_column_name, "is_rename": false}) %}
    {%- endif %}
{%- endfor %}

{%- do column_list.extend(renamed_columns) %}

{% endmacro %}
