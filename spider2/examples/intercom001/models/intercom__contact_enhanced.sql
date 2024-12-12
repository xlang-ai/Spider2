--take latest contact history to get the last update for the contact
with contact_latest as (
  select *
  from {{ var('contact_history') }}
  where coalesce(_fivetran_active, true)
),

--If you use the contact company table this will be included, if not it will be ignored.
{% if var('intercom__using_contact_company', True) %}
contact_company_history as (
  select *
  from {{ var('contact_company_history') }}
),

company_history as (
  select *
  from {{ var('company_history') }}
),
{% endif %}  

--If you use contact tags this will be included, if not it will be ignored.
{% if var('intercom__using_contact_tags', True) %}
contact_tags as (
  select *
  from {{ var('contact_tag_history') }}
),

tags as (
  select *
  from {{ var('tag') }}
),

--Aggregates the tags associated with a single contact into an array.
contact_tags_aggregate as (
  select
    contact_latest.contact_id,
    {{ fivetran_utils.string_agg('distinct tags.name', "', '" ) }} as all_contact_tags
  from contact_latest

  left join contact_tags
      on contact_tags.contact_id = contact_latest.contact_id
    
    left join tags
      on tags.tag_id = contact_tags.tag_id

  group by 1  
),
{% endif %}

--If you use the contact company table this will be included, if not it will be ignored.
{% if var('intercom__using_contact_company', True) %}
contact_company_array as (
  select
    contact_latest.contact_id,
    {{ fivetran_utils.string_agg('distinct company_history.company_name', "', '" ) }} as all_contact_company_names

  from contact_latest
  
  left join contact_company_history
    on contact_company_history.contact_id = contact_latest.contact_id

  left join company_history
    on company_history.company_id = contact_company_history.company_id

  group by 1
),
{% endif %}

--Joins the contact table with tags (if used) as well as the contact company (if used).
final as (
  select
    contact_latest.*
        
    --If you use contact tags this will be included, if not it will be ignored.
    {% if var('intercom__using_contact_tags', True) %}
    ,contact_tags_aggregate.all_contact_tags
    {% endif %}

    --If you use the contact company table this will be included, if not it will be ignored.
    {% if var('intercom__using_contact_company', True) %}
    ,contact_company_array.all_contact_company_names
    {% endif %}

  from contact_latest

  --If you use the contact company table this will be included, if not it will be ignored.
  {% if var('intercom__using_contact_company', True) %}
  left join contact_company_array
    on contact_company_array.contact_id = contact_latest.contact_id
  {% endif %}

  --If you use the contact tags table this will be included, if not it will be ignored.
  {% if var('intercom__using_contact_tags', True) %}
  left join contact_tags_aggregate
      on contact_tags_aggregate.contact_id = contact_latest.contact_id
  {% endif %}
)

select *
from final 
