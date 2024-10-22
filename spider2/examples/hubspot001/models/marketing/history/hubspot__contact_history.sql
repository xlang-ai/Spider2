{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_property_enabled','hubspot_contact_property_history_enabled'])) }}

with history as (

    select *
    from {{ var('contact_property_history') }}

), windows as (

    select
        contact_id,
        field_name,
        change_source,
        change_source_id,
        change_timestamp as valid_from,
        new_value,
        lead(change_timestamp) over (partition by contact_id, field_name order by change_timestamp) as valid_to
    from history

), surrogate as (

    select 
        windows.*,
        {{ dbt_utils.generate_surrogate_key(['field_name','contact_id','valid_from']) }} as id
    from windows

)

select *
from surrogate