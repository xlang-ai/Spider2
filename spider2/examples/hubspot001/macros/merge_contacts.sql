{% macro merge_contacts() -%}

{{ adapter.dispatch('merge_contacts', 'hubspot') () }}

{% endmacro %}

{% macro default__merge_contacts() %}
{# bigquery  #}
    select
        contacts.contact_id,
        split(merges, ':')[offset(0)] as vid_to_merge

    from contacts
    cross join 
        unnest(cast(split(calculated_merged_vids, ";") as array<string>)) as merges

{% endmacro %}

{% macro snowflake__merge_contacts() %}
    select
        contacts.contact_id,
        split_part(merges.value, ':', 0) as vid_to_merge
    
    from contacts
    cross join 
        table(flatten(STRTOK_TO_ARRAY(calculated_merged_vids, ';'))) as merges

{% endmacro %}

{% macro redshift__merge_contacts() %}
	select
        unnest_vid_array.contact_id,
        split_part(cast(vid_to_merge as {{ dbt.type_string() }}) ,':',1) as vid_to_merge
    from (
        select 
            contacts.contact_id,
            split_to_array(calculated_merged_vids, ';') as super_calculated_merged_vids
        from contacts
    ) as unnest_vid_array, unnest_vid_array.super_calculated_merged_vids as vid_to_merge

{% endmacro %}

{% macro postgres__merge_contacts() %}
    select
        contacts.contact_id,
        split_part(merges, ':', 1) as vid_to_merge

    from contacts
    cross join 
        unnest(string_to_array(calculated_merged_vids, ';')) as merges

{% endmacro %}

{% macro spark__merge_contacts() %}
{# databricks and spark #}
    select
        contacts.contact_id,
        split_part(merges, ':', 1) as vid_to_merge
    from contacts
    cross join (
        select 
            contact_id, 
            explode(split(calculated_merged_vids, ';')) as merges from contacts
    ) as merges_subquery 
    where contacts.contact_id = merges_subquery.contact_id

{% endmacro %}

{% macro duckdb__merge_contacts() %}
    select
        contacts.contact_id,
        split_part(merges, ':', 1) as vid_to_merge
    from contacts
    cross join unnest(string_split(cast(calculated_merged_vids as varchar), ';')) as merges
{% endmacro %}
