--To disable this model, set the intercom__using_contact_company variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_contact_company', True)) }}

with company_history as (
  select *
  from {{ var('company_history') }}
),

--If you use company tags this will be included, if not it will be ignored.
{% if var('intercom__using_company_tags', True) %}
company_tags as (
  select *
  from {{ var('company_tag_history') }}
),

tags as (
  select *
  from {{ var('tag') }}
),

--Aggregates the tags associated with a single company into an array.
company_tags_aggregate as (
  select
    company_history.company_id,
    {{ fivetran_utils.string_agg('distinct tags.name', "', '" ) }} as all_company_tags
  from company_history

  left join company_tags
      on company_tags.company_id = company_history.company_id
    
    left join tags
      on tags.tag_id = company_tags.tag_id

  group by 1
),
{% endif %}

--Enriches the base company table with tag details (if company tags are used).
enhanced as (
    select
        company_history.*

        --If you use company tags this will be included, if not it will be ignored.
        {% if var('intercom__using_company_tags', True) %}
        ,company_tags_aggregate.all_company_tags
        {% endif %}

    from company_history

    --If you use company tags this will be included, if not it will be ignored.
    {% if var('intercom__using_company_tags', True) %}
    left join company_tags_aggregate
      on company_tags_aggregate.company_id = company_history.company_id
    {% endif %}
)

select * 
from enhanced