with conversation_part_history as (
    select *
    from {{ var('conversation_part_history') }}
),

--Returns each distinct admin author(s) that were associated with a single conversation.
admin_conversation_parts as (
    select distinct
        conversation_id,
        author_id
    from conversation_part_history

    where author_type = 'admin'

),

--Aggregates the admin_conversation_parts author_ids into an array to show all admins associated with a single conversation within one cell.
admin_conversation_aggregates as (
    select 
        conversation_id,
        {{ fivetran_utils.string_agg('distinct author_id', "', '" ) }} as conversation_admins
    from admin_conversation_parts
    
    group by 1
),

--Returns each distinct contact (as either a user or lead) author(s) that were associated with a single conversation.
contact_conversation_parts as (
    select distinct
        conversation_id,
        author_id
    from conversation_part_history

    where author_type in ('user', 'lead') 

),

--Aggregates the contact_conversation_parts author_ids into an array to show all contacts associated with a single conversation within one cell.
contact_conversation_aggregates as (
    select 
        conversation_id,
        {{ fivetran_utils.string_agg('distinct author_id', "', '" ) }} as conversation_contacts
    from contact_conversation_parts

    group by 1
),

--Joins the admin and contact author aggregate CTEs on the conversation_id.
final as (
    select
        admin_conversation_aggregates.conversation_id,
        admin_conversation_aggregates.conversation_admins,
        contact_conversation_aggregates.conversation_contacts
    from admin_conversation_aggregates

    left join contact_conversation_aggregates
        on contact_conversation_aggregates.conversation_id = admin_conversation_aggregates.conversation_id
)

select *
from final