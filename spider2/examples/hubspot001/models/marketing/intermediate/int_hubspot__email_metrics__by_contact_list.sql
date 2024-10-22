{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_contact_list_member_enabled','hubspot_contact_enabled','hubspot_email_event_sent_enabled']), materialized='table') }}

with email_sends as (

    select *
    from {{ ref('hubspot__email_sends') }}

), contact_list_member as (

    select *
    from {{ var('contact_list_member') }}

), joined as (

    select
        email_sends.*,
        contact_list_member.contact_list_id
    from email_sends
    left join contact_list_member
        using (contact_id)
    where contact_list_member.contact_list_id is not null

), email_metrics as (
    {% set email_metrics = adjust_email_metrics('hubspot__email_sends', 'email_metrics') %}
    select 
        contact_list_id,
        {% for metric in email_metrics %}
        sum({{ metric }}) as total_{{ metric }},
        count(distinct case when {{ metric }} > 0 then email_send_id end) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from joined
    group by 1

)

select *
from email_metrics