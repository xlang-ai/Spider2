{{ config(enabled=var('apple_store__using_subscriptions', False)) }}

with base as (

    select *
    from {{ var('sales_subscription_events') }}
),

app as (
    
    select *
    from {{ var('app') }}
),

sales_account as (
    
    select * 
    from {{ var('sales_account') }}
),

filtered as (

    select *
    from base 
    where lower(event)
        in (
            {% for event_val in var('apple_store__subscription_events') %}
                {% if loop.index0 != 0 %}
                , 
                {% endif %}
                '{{ var("apple_store__subscription_events")[loop.index0] | trim | lower }}'
            {% endfor %}   
        )
),

pivoted as (
    
    select
        date_day
        , source_relation
        , account_id
        , app_name
        , subscription_name
        , country
        , state
        {% for event_val in var('apple_store__subscription_events') %}
        , sum(case when lower(event) = '{{ event_val | trim | lower }}' then quantity else 0 end) as {{ 'event_' ~ event_val | replace(' ', '_') | trim | lower }}
        {% endfor %}
    from filtered
    {{ dbt_utils.group_by(7) }}
),

joined as (

    select 
        pivoted.source_relation,
        pivoted.date_day,
        pivoted.account_id,
        sales_account.account_name,
        app.app_id,
        pivoted.app_name,
        pivoted.subscription_name,
        pivoted.country,
        pivoted.state
        {% for event_val in var('apple_store__subscription_events') %}
        , pivoted.{{ 'event_' ~ event_val | replace(' ', '_') | trim | lower }}
        {% endfor %}
    from pivoted
    left join app 
        on pivoted.app_name = app.app_name
        and pivoted.source_relation = app.source_relation
    left join sales_account 
        on pivoted.account_id = sales_account.account_id
        and pivoted.source_relation = sales_account.source_relation
)

select * 
from joined