{% macro adjust_email_metrics(base_ref, var_name) %}

{% set base_cols = dbt_utils.get_filtered_columns_in_relation(ref(base_ref))|map('lower') %}

{% set default_metrics = ['bounces', 'clicks', 'deferrals', 'deliveries', 'drops', 'forwards', 'opens', 'prints', 'spam_reports', 'unsubscribes'] %}
{% set email_metrics = var(var_name, default_metrics)|map('lower') %}

{# Only keep metrics found in the base ref #}
{% set adjusted_cols = email_metrics|select('in', base_cols)|list %}

{{ return(adjusted_cols) }}

{% endmacro %}