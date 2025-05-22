{% macro lead_history_columns_warning() %}

{% if not var('lead_history_columns') %}
{{ log(
    """
    Warning: You have passed an empty list to the 'lead_history_columns'.
    As a result, you won't see the history of any columns in the 'marketo__lead_history' model.
    """,
    info=True
) }}
{% endif %}

{% endmacro %}