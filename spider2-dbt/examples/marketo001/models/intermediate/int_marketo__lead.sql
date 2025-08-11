{{ config(materialized='view') }}

with leads as(
    select * 
    from {{ var('lead') }}

), activity_merge_leads as (
    select * 
    from {{ var('activity_merge_leads') }}

), unique_merges as (

    select 
        cast(lead_id as {{ dbt.type_int() }}) as lead_id,
        {{ fivetran_utils.string_agg('distinct merged_lead_id', "', '") }} as merged_into_lead_id

    from activity_merge_leads
    group by 1 

/*If you do not use the activity_delete_lead table, set var marketo__activity_delete_lead_enabled 
to False. Default is True*/
{% if var('marketo__activity_delete_lead_enabled', True) %}
), deleted_leads as (

    select distinct lead_id
    from {{ var('activity_delete_lead') }}
    
{% endif %}

), joined as (

    select 
        leads.*,

        /*If you do not use the activity_delete_lead table, set var marketo__activity_delete_lead_enabled 
        to False. Default is True*/
        {% if var('marketo__activity_delete_lead_enabled', True) %}
        case when deleted_leads.lead_id is not null then True else False end as is_deleted,
        {% else %}
        null as is_deleted,
        {% endif %}

        unique_merges.merged_into_lead_id,
        case when unique_merges.merged_into_lead_id is not null then True else False end as is_merged
    from leads

    /*If you do not use the activity_delete_lead table, set var marketo__activity_delete_lead_enabled 
    to False. Default is True*/
    {% if var('marketo__activity_delete_lead_enabled', True) %}
    left join deleted_leads on leads.lead_id = deleted_leads.lead_id
    {% endif %}

    left join unique_merges on leads.lead_id = unique_merges.lead_id 
)

select *
from joined