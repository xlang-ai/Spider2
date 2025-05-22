--This model will only run if you have the underlying opportunity line item table.
{{ config(enabled=var('salesforce__opportunity_line_item_enabled', True))}}
with opportunity_line_item as (
    
    select *
    from {{ var('opportunity_line_item') }}
),

-- If using product_2 table, the following will be included, otherwise it will not.
{% if var('salesforce__product_2_enabled', True) %}
product_2 as (

    select * 
    from {{ var('product_2') }}
),
{% endif %}


final as (

    select
        oli.opportunity_line_item_id,
        oli.opportunity_line_item_name,
        oli.opportunity_line_item_description,
        oli.opportunity_id,
        row_number() over (partition by oli.opportunity_id order by oli.created_date) as line_item_index,
        count(opportunity_line_item_id) over (partition by oli.opportunity_id) as total_line_items,
        oli.created_date,
        oli.last_modified_date,
        oli.service_date,
        oli.pricebook_entry_id,
        oli.product_2_id,
        oli.list_price,
        oli.quantity,
        oli.unit_price,
        oli.total_price,
        oli.has_quantity_schedule,
        oli.has_revenue_schedule

        {% if var('salesforce__product_2_enabled', True) %}
        ,
        product_2.product_2_name,
        product_2.product_code,
        product_2.product_2_description,
        product_2.external_id as product_external_id,
        product_2.family as product_family,
        product_2.is_active as product_is_active,
        product_2.is_archived as product_is_archived,
        product_2.is_deleted as product_is_deleted,
        product_2.number_of_quantity_installments as product_number_of_quantity_installments,
        product_2.quantity_installment_period as product_quantity_installment_period,
        product_2.quantity_schedule_type as product_quantity_schedule_type,
        product_2.quantity_unit_of_measure as product_quantity_unit_of_measure,
        product_2.number_of_revenue_installments as product_number_of_revenue_installments,
        product_2.revenue_installment_period as product_revenue_installment_period,
        product_2.revenue_schedule_type as product_revenue_schedule_type
        {% endif %}

        --The below script allows for pass through columns.
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='salesforce__opportunity_line_item_pass_through_columns', identifier='oli') }}

        {% if var('salesforce__product_2_enabled', True) %}
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='salesforce__product_2_pass_through_columns', identifier='product_2') }}
        {% endif %}

    from opportunity_line_item as oli

    {% if var('salesforce__product_2_enabled', True) %}
    left join product_2
        on oli.product_2_id = product_2.product_2_id
    {% endif %}
)

select * 
from final