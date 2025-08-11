{# 
This model unions together contacts from the XM Directory and Research Core Contact endpoints.
Research Core contacts will be deprecated in 2023 by Qualtrics
#}
with directory_contact as (

    select *
    from {{ var('directory_contact') }}
),

contact_mailing_list_membership as (

    select * 
    from {{ var('contact_mailing_list_membership') }}
),

-- in XM directory a contact can belong to multiple mailing lists within a directory
-- need to split counts and string_aggs on redshift 
count_mailing_lists as (

    select 
        directory_id,
        contact_id,
        source_relation,
        count(distinct case when not is_unsubscribed then mailing_list_id else null end) as count_mailing_lists_subscribed_to,
        count(distinct case when is_unsubscribed then mailing_list_id else null end) as count_mailing_lists_unsubscribed_from

    from contact_mailing_list_membership
    group by 1,2,3
),

-- in XM directory a contact can belong to multiple mailing lists within a directory
-- need to split counts and string_aggs on redshift 
agg_mailing_lists as (

    select 
        directory_id,
        contact_id,
        source_relation,
        {{ fivetran_utils.string_agg('mailing_list_id', "', '") }} as mailing_list_ids

    from contact_mailing_list_membership
    group by 1,2,3
),

directory_contact_join as (

    select
        directory_contact.*,
        count_mailing_lists.count_mailing_lists_subscribed_to,
        count_mailing_lists.count_mailing_lists_unsubscribed_from,
        agg_mailing_lists.mailing_list_ids
    from directory_contact
    left join agg_mailing_lists
        on directory_contact.contact_id = agg_mailing_lists.contact_id
        and directory_contact.directory_id = agg_mailing_lists.directory_id 
        and directory_contact.source_relation = agg_mailing_lists.source_relation
    left join count_mailing_lists
        on directory_contact.contact_id = count_mailing_lists.contact_id
        and directory_contact.directory_id = count_mailing_lists.directory_id 
        and directory_contact.source_relation = count_mailing_lists.source_relation
),

{% if var('qualtrics__using_core_contacts', false) %}
core_contact as (

    select *
    from {{ var('core_contact') }}
),

-- Roll up mailing lists since contacts in the XM directory endpoint can belong to multiple (or none)
-- need to split counts and string_aggs on redshift 
count_core_mailing_lists as (

    select 
        contact_id,
        source_relation,
        count(distinct case when not is_unsubscribed then mailing_list_id else null end) as count_mailing_lists_subscribed_to,
        count(distinct case when is_unsubscribed then mailing_list_id else null end) as count_mailing_lists_unsubscribed_from

    from core_contact
    group by 1,2
),

-- Roll up mailing lists since contacts in the XM directory endpoint can belong to multiple (or none)
-- need to split counts and string_aggs on redshift 
agg_core_mailing_lists as (

    select 
        contact_id,
        source_relation,
        {{ fivetran_utils.string_agg('mailing_list_id', "', '") }} as mailing_list_ids

    from core_contact
    group by 1,2
),

core_contact_join  as (

    select
        core_contact.*,
        count_core_mailing_lists.count_mailing_lists_subscribed_to,
        count_core_mailing_lists.count_mailing_lists_unsubscribed_from,
        agg_core_mailing_lists.mailing_list_ids
    from core_contact
    left join agg_core_mailing_lists
        on core_contact.contact_id = agg_core_mailing_lists.contact_id
        and core_contact.source_relation = agg_core_mailing_lists.source_relation
    left join count_core_mailing_lists
        on core_contact.contact_id = count_core_mailing_lists.contact_id
        and core_contact.source_relation = count_core_mailing_lists.source_relation
),

final as (

    select
        contact_id,
        false as is_xm_directory_contact,
        true as is_research_core_contact,
        null as directory_id,
        email,
        email_domain,
        first_name,
        last_name,
        external_data_reference,
        language,
        null as is_unsubscribed_from_directory,
        null as unsubscribed_from_directory_at,
        null as last_modified_at,
        mailing_list_ids,
        count_mailing_lists_subscribed_to,
        count_mailing_lists_unsubscribed_from,
        _fivetran_synced as created_at,
        source_relation

        {% if var('qualtrics__directory_contact_pass_through_columns', none) %}
            {% for field in var('qualtrics__directory_contact_pass_through_columns') %}
                , null as {{ field.alias if field.alias else field.name }}
            {% endfor %}
        {% endif %}

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='qualtrics__core_contact_pass_through_columns', identifier='core_contact_join') }}


    from core_contact_join
    union all 

{% else %}
final as (
{% endif %}

    select
        contact_id,
        true as is_xm_directory_contact,
        false as is_research_core_contact,
        directory_id,
        email,
        email_domain,
        first_name,
        last_name,
        ext_ref as external_data_reference,
        language,
        is_unsubscribed_from_directory,
        unsubscribed_from_directory_at,
        last_modified_at,
        mailing_list_ids,
        count_mailing_lists_subscribed_to,
        count_mailing_lists_unsubscribed_from,
        created_at,
        source_relation
        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='qualtrics__directory_contact_pass_through_columns') }}

        {% if var('qualtrics__core_contact_pass_through_columns', none) %}
            {% for field in var('qualtrics__core_contact_pass_through_columns') %}
                , null as {{ field.alias if field.alias else field.name }}
            {% endfor %}
        {% endif %}

    from directory_contact_join
)

select *
from final