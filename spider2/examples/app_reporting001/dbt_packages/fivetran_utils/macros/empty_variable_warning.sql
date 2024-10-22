{% macro empty_variable_warning(variable, downstream_model) %}

{% if not var(variable) %}
{{ log(
    """
    Warning: You have passed an empty list to the """ ~ variable ~ """.
    As a result, you won't see the history of any columns in the """ ~ downstream_model ~ """ model.
    """,
    info=True
) }}
{% endif %}

{% endmacro %}