{% macro timestamp_add(datepart, interval, from_timestamp) -%}

{{ adapter.dispatch('timestamp_add', 'fivetran_utils') (datepart, interval, from_timestamp) }}

{%- endmacro %}


{% macro default__timestamp_add(datepart, interval, from_timestamp) %}

    timestampadd(
        {{ datepart }},
        {{ interval }},
        {{ from_timestamp }}
        )

{% endmacro %}


{% macro bigquery__timestamp_add(datepart, interval, from_timestamp) %}

        timestamp_add({{ from_timestamp }}, interval  {{ interval }} {{ datepart }})

{% endmacro %}

{% macro redshift__timestamp_add(datepart, interval, from_timestamp) %}

        dateadd(
        {{ datepart }},
        {{ interval }},
        {{ from_timestamp }}
        )

{% endmacro %}

{% macro postgres__timestamp_add(datepart, interval, from_timestamp) %}

    {{ from_timestamp }} + ((interval '1 {{ datepart }}') * ({{ interval }}))

{% endmacro %}

{% macro spark__timestamp_add(datepart, interval, from_timestamp) %}

    {{ dbt.dateadd(datepart, interval, from_timestamp) }}
        
{% endmacro %}
