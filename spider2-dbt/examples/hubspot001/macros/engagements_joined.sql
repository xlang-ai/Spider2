{% macro engagements_joined(base_model) %}

with base as (

    select *
    from {{ base_model }}

), engagements as (

    select *
    from {{ ref('hubspot__engagements') }}

), joined as (

    select 
        {{ dbt_utils.star(from=base_model, relation_alias="base",except=["_fivetran_deleted", "created_timestamp", "occurred_timestamp", "owner_id"]) }},
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_contact_enabled']) %} engagements.contact_ids, {% endif %}
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_deal_enabled']) %} engagements.deal_ids, {% endif %}
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_company_enabled']) %} engagements.company_ids, {% endif %}
        coalesce(engagements.is_active, not base._fivetran_deleted) as is_active,
        coalesce(engagements.created_timestamp, base.created_timestamp) as created_timestamp,
        coalesce(engagements.occurred_timestamp, base.occurred_timestamp) as occurred_timestamp,
        coalesce(engagements.owner_id, base.owner_id) as owner_id
    from base
    left join engagements
        on base.engagement_id = engagements.engagement_id

)

select *
from joined

{% endmacro %}