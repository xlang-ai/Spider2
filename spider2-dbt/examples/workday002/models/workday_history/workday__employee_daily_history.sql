-- depends_on: {{ ref('int_workday__employee_history') }}
{{ config(enabled=var('employee_history_enabled', False)) }}

{% if execute %} 
    {% set first_last_date_query %}
    with min_max_values as (

        select 
            min(_fivetran_start) as min_start,
            max(_fivetran_start) as max_start 
        from {{ ref('int_workday__employee_history') }}
    )

    select 
        min_start,
        case when max_start >= {{ dbt.current_timestamp() }}
            then max_start
            else {{ dbt.date_trunc('day', dbt.current_timestamp()) }} 
        end as max_start
    from min_max_values
    
    {% endset %}

    {% set start_date = run_query(first_last_date_query).columns[0][0]|string %}
    {% set last_date = run_query(first_last_date_query).columns[1][0]|string %}

{# If only compiling, creates range going back 1 year #}
{% else %} 
    {% set start_date = dbt.dateadd("year", "-1", "current_date") %} -- One year in the past for first date
    {% set last_date = dbt.dateadd("day", "-1", "current_date") %} -- Yesterday as last date
{% endif %}


with spine as (
    {# Prioritizes variables over calculated dates #}
    {# Arbitrarily picked employee_history_start_date variable value. Choose a more appropriate default if necessary. #}
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date = "greatest(cast('" ~ start_date[0:10] ~ "' as date), cast('" ~ var('employee_history_start_date','2005-03-01') ~ "' as date))", 
        end_date = "cast('" ~ last_date[0:10] ~ "'as date)"
        )
    }}
),

employee_history as (

    select *        
    from {{ ref('int_workday__employee_history') }}
),

order_daily_values as (

    select 
        *,
        row_number() over (
            partition by _fivetran_date, employee_id
            order by _fivetran_start desc) as row_num    
    from employee_history
),

get_latest_daily_value as (

    select * 
    from order_daily_values
    where row_num = 1
),

daily_history as (

    select 
        {{ dbt_utils.generate_surrogate_key(['spine.date_day','get_latest_daily_value.history_unique_key']) }} as employee_day_id,
        cast(spine.date_day as date) as date_day,
        get_latest_daily_value.*
    from get_latest_daily_value
    join spine on get_latest_daily_value._fivetran_start <= cast(spine.date_day as {{ dbt.type_timestamp() }})
        and get_latest_daily_value._fivetran_end >= cast(spine.date_day as {{ dbt.type_timestamp() }})
)

select * 
from daily_history