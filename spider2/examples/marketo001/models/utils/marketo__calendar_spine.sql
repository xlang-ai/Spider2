with spine as (

    {% if execute %}
    {% set first_date_query %}
        select  min( created_at ) as min_date from {{ source('marketo','lead') }}
    {% endset %}

    -- can set first date with var marketo__first_date; 
    -- default first date is the minimum date of stg_marketo__lead
    {% set first_date = var('marketo__first_date', run_query(first_date_query).columns[0][0]|string) %}
    
        {% if target.type == 'postgres' %}
            {% set first_date_adjust = "cast('" ~ first_date[0:10] ~ "' as date)" %}

        {% else %}
            {% set first_date_adjust = "cast('" ~ first_date[0:10] ~ "' as date)" %}


        {% endif %}

    {% else %} {% set first_date_adjust = "2016-01-01" %}
    
    {% endif %}

{{
    dbt_utils.date_spine(
        datepart = "day", 
        start_date = first_date_adjust,
        end_date = dbt.dateadd("week", 1, "current_date")
    )   
}}

), recast as (
    select cast(date_day as date) as date_day
    from spine
)

select *
from recast