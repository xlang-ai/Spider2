with spine as (
    
    {# Calculates first and last dates if at least one is not manually set #}
    {% if execute %}
        {% if not var('recharge_first_date', None) or not var('recharge_last_date', None) %}
            {% set date_query %}
                select  
                    cast(min(created_at) as {{ dbt.type_timestamp() }}) as min_date,
                    cast(max(created_at) as {{ dbt.type_timestamp() }}) as max_date 
                from {{ source('recharge','charge') }}
                {% endset %}
            {% set calc_first_date = run_query(date_query).columns[0][0]|string %}
            {% set calc_last_date = run_query(date_query).columns[1][0]|string %}
        {% endif %}

    {# If only compiling, creates range going back 1 year #}
    {% else %} 
        {% set calc_first_date = dbt.dateadd("year", "-1", "current_date") %}
        {% set calc_last_date = dbt.current_timestamp_backcompat() %}

    {% endif %}

    {# Prioritizes variables over calculated dates #}
    {% set first_date = var('recharge_first_date', calc_first_date)|string %}
    {% set last_date = var('recharge_last_date', calc_last_date)|string %}

{{ dbt_utils.date_spine(
    datepart = "day",
    start_date = "cast('" ~ first_date[0:10] ~ "'as date)",
    end_date = "cast('" ~ last_date[0:10] ~ "'as date)"
    )
}}
)

select *
from spine