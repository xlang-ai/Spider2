{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled'])) }}

with contacts as (

    select *
    from {{ var('contact') }}
), contact_merge_audit as (
    select
        contacts.contact_id,
        split_part(merges.value, ':', 1) as vid_to_merge
    from contacts
    cross join unnest(string_split(cast(calculated_merged_vids as varchar), ';')) as merges(value)

), contact_merge_removal as (
    select 
        contacts.*
    from contacts
    
    left join contact_merge_audit
        on cast(contacts.contact_id as {{ dbt.type_string() }}) = cast(contact_merge_audit.vid_to_merge as {{ dbt.type_string() }})
    
    where contact_merge_audit.vid_to_merge is null
)

select *
from contact_merge_removal
