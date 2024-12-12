{% if var('salesforce__lead_enabled', True) -%}
-- depends_on: {{ var('lead') }}
{% else -%}
-- depends_on: {{ var('opportunity') }}
{% endif %}  
with spine as (

    {% if execute and flags.WHICH in ('run', 'build') %}

    {%- set first_date_query %}
        select 
            coalesce(
                min(cast(created_date as date)), 
                cast({{ dbt.dateadd("month", -1, "current_date") }} as date)
                ) as min_date
        {% if var('salesforce__lead_enabled', True) %}
            from {{ var('lead') }}
        {% else %}
            from {{ var('opportunity') }}
        {% endif %}  
    {% endset -%}

    {% set last_date_query %}
        select 
            coalesce(
                greatest(max(cast(created_date as date)), cast(current_date as date)),
                cast(current_date as date)
                ) as max_date
        {% if var('salesforce__lead_enabled', True) %}
            from {{ var('lead') }}
        {% else %}
            from {{ var('opportunity') }}
        {% endif %}  
    {% endset -%}

    {% else %}

    {%- set first_date_query%}
        select cast({{ dbt.dateadd("month", -1, "current_date") }} as date)
    {% endset -%}

    {% set last_date_query %}
        select cast({{ dbt.current_timestamp_backcompat() }} as date)
    {% endset -%}

    {% endif %}

    {%- set first_date = dbt_utils.get_single_value(first_date_query) %}
    {%- set last_date = dbt_utils.get_single_value(last_date_query) %}

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ first_date ~ "' as date)",
        end_date=dbt.dateadd("day", 1, "cast('" ~ last_date  ~ "' as date)")
        )
    }}
)

select * 
from spine