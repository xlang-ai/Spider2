{% macro shopify_partition_by_cols(base_col, source_relation='source_relation') %}

{{ adapter.dispatch('shopify_partition_by_cols', 'shopify') (base_col, source_relation) }}

{%- endmacro %}

{# Benefits mainly redshift since upstream models are views, but applies to all other warehouses. #}
{% macro default__shopify_partition_by_cols(base_col, source_relation='source_relation') %}
    {%- if var('shopify_union_schemas', false) or var('shopify_union_databases', false) -%}
    {{ base_col }}, {{ source_relation }}
    {%- else %}
    {{ base_col }}
    {%- endif %}

{% endmacro %}