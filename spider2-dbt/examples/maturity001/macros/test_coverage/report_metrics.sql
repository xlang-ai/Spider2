{# 
    This macro is not super useful in its current form -- would love to see this actually materialized in a table rather than just logged to stdout!
    This is mostly to show how to start thinking more introspectively about your project
    The Metadata API is the most robust way to operationalize these kinds of metrics!
 #}

{% macro report_metrics() %}

    {% if execute %}
        {{ log('', info=true)}} {# whitespace to print nicely #}
        {{ get_test_coverage() }}
        {{ get_test_to_model_ratio() }}  
        {{ log('', info=true)}} {# whitespace to print nicely #}
    {% endif %}

{% endmacro %}