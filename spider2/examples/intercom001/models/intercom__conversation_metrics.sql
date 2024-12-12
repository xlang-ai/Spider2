with conversation_part_aggregates as (
  select *
  from {{ ref('int_intercom__conversation_part_aggregates') }}
),

conversation_enhanced as(
  select *
  from {{ ref('intercom__conversation_enhanced') }}
),

--Returns time difference aggregates to the conversations_enhanced model. All time metrics are broken down to the second, then divided by 60 to reflect minutes without rounding errors.
final as (
  select 
    conversation_enhanced.*,
    conversation_part_aggregates.count_reopens,
    conversation_part_aggregates.count_total_parts,
    conversation_part_aggregates.count_assignments,
    conversation_part_aggregates.first_contact_reply_at,
    conversation_part_aggregates.first_assignment_at,
    round(cast(({{ dbt.datediff("conversation_enhanced.conversation_created_at", "conversation_part_aggregates.first_assignment_at", 'second') }}/60) as numeric), 2) as time_to_first_assignment_minutes,
    conversation_part_aggregates.first_admin_response_at,
    round(cast(({{ dbt.datediff("conversation_enhanced.conversation_created_at", "conversation_part_aggregates.first_admin_response_at", 'second') }}/60) as numeric), 2) as time_to_first_response_minutes,
    round(cast(({{ dbt.datediff("conversation_part_aggregates.first_contact_reply_at", "conversation_enhanced.first_admin_close_at", 'second') }} /60) as numeric), 2) as time_to_admin_first_close_minutes,
    round(cast(({{ dbt.datediff("conversation_part_aggregates.first_contact_reply_at", "conversation_enhanced.first_close_at", 'second') }} /60) as numeric), 2) as time_to_first_close_minutes,
    conversation_part_aggregates.first_reopen_at,
    conversation_part_aggregates.last_assignment_at,
    round(cast(({{ dbt.datediff("conversation_enhanced.conversation_created_at", "conversation_part_aggregates.last_assignment_at", 'second') }} /60) as numeric), 2) as time_to_last_assignment_minutes,
    conversation_part_aggregates.last_contact_reply_at,
    conversation_part_aggregates.last_admin_response_at,
    conversation_part_aggregates.last_reopen_at,
    round(cast(({{ dbt.datediff("conversation_part_aggregates.first_contact_reply_at", "conversation_enhanced.last_admin_close_at", 'second') }} /60) as numeric), 2) as time_to_admin_last_close_minutes,
    round(cast(({{ dbt.datediff("conversation_part_aggregates.first_contact_reply_at", "conversation_enhanced.last_close_at", 'second') }} /60) as numeric), 2) as time_to_last_close_minutes
  from conversation_part_aggregates

  left join conversation_enhanced
    on conversation_enhanced.conversation_id = conversation_part_aggregates.conversation_id
  
)

select *
from final