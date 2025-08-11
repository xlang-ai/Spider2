with expenses as (

    select *
    from {{ ref('int_quickbooks__expenses_union') }}
),

{% if fivetran_utils.enabled_vars_one_true(['using_sales_receipt','using_invoice']) %}
sales as (

    select *
    from {{ ref('int_quickbooks__sales_union') }}
),
{% endif %}

final as (
    
    select *
    from expenses

    {% if fivetran_utils.enabled_vars_one_true(['using_sales_receipt','using_invoice']) %}
    union all

    select *
    from sales
    {% endif %}
)

select *
from final