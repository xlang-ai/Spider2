with latest_conversation_part as (
  select *
  from {{ var('conversation_part_history') }}
  where coalesce(_fivetran_active, true)
),

latest_conversation as (
  select *
  from {{ var('conversation_history') }}
  where coalesce(_fivetran_active, true)
),

--Aggregates conversation part data related to a single conversation from the int_intercom__latest_conversation model. See below for specific aggregates.
final as (
  select 
    latest_conversation.conversation_id,
    latest_conversation.created_at as conversation_created_at,
    count(latest_conversation_part.conversation_part_id) as count_total_parts,
    min(case when latest_conversation_part.part_type = 'comment' and latest_conversation_part.author_type in ('lead','user') then latest_conversation_part.created_at else null end) as first_contact_reply_at,
    min(case when latest_conversation_part.part_type like '%assignment%' then latest_conversation_part.created_at else null end) as first_assignment_at,
    min(case when latest_conversation_part.part_type in ('comment','assignment') and latest_conversation_part.author_type = 'admin' and latest_conversation_part.body is not null then latest_conversation_part.created_at else null end) as first_admin_response_at,
    min(case when latest_conversation_part.part_type = 'open' then latest_conversation_part.created_at else null end) as first_reopen_at,
    max(case when latest_conversation_part.part_type like '%assignment%' then latest_conversation_part.created_at else null end) as last_assignment_at,
    max(case when latest_conversation_part.part_type = 'comment' and latest_conversation_part.author_type in ('lead','user') then latest_conversation_part.created_at else null end) as last_contact_reply_at,
    max(case when latest_conversation_part.part_type in ('comment','assignment') and latest_conversation_part.author_type = 'admin' and latest_conversation_part.body is not null then latest_conversation_part.created_at else null end) as last_admin_response_at,
    max(case when latest_conversation_part.part_type = 'open' then latest_conversation_part.created_at else null end) as last_reopen_at,
    sum(case when latest_conversation_part.part_type like '%assignment%' then 1 else 0 end) as count_assignments,
    sum(case when latest_conversation_part.part_type = 'open' then 1 else 0 end) as count_reopens
  from latest_conversation

  left join latest_conversation_part
    on latest_conversation.conversation_id = latest_conversation_part.conversation_id

  group by 1, 2
  
)

select * 
from final