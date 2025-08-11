{{ config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_contact_merge_audit_enabled', false))) }}

select {{ dbt_utils.star(source('hubspot','contact_merge_audit')) }}
from {{ var('contact_merge_audit') }}