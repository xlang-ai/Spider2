{{ config(enabled=var('shopify_using_fulfillment_event', false)) }}

with fulfillment_event as (

    select *
    from {{ var('shopify_fulfillment_event') }}
),

fulfillment_aggregates as (

    select 
        source_relation,
        cast({{ dbt.date_trunc('day','happened_at') }} as date) as date_day

        {% for status in ['attempted_delivery', 'delayed', 'delivered', 'failure', 'in_transit', 'out_for_delivery', 'ready_for_pickup', 'picked_up', 'label_printed', 'label_purchased', 'confirmed']%}
        , count(distinct case when lower(status) = '{{ status }}' then fulfillment_id end) as count_fulfillment_{{ status }}
        {% endfor %}
    
    from fulfillment_event
    group by 1,2

)

select *
from fulfillment_aggregates