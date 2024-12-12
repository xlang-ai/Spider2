with customers as (
    select *
    from {{ ref('recharge__customer_details') }}

), churn_types as (
    select 
        customers.*,
        case when calculated_subscriptions_active_count > 0 and has_valid_payment_method = true
            then false else true
            end as is_churned,
        {# Definitions of churn reasons per recharge docs #}
        case when calculated_subscriptions_active_count = 0 and has_valid_payment_method = false
            then 'passive cancellation'
        when calculated_subscriptions_active_count = 0 and has_valid_payment_method = true
            then 'active cancellation'
        when calculated_subscriptions_active_count > 0 and has_valid_payment_method = false
            then 'charge error'
        else cast(null as {{ dbt.type_string() }})
        end as churn_type
    from customers
)

select *
from churn_types