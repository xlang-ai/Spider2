with issue_field_history as (
    
    select *
    from {{ ref('int_jira__issue_field_history') }}

), 

filtered as (
    -- we're only looking at assignments and resolutions, which are single-field values
    select *
    from issue_field_history

    where (lower(field_id) = 'assignee'
    or lower(field_id) = 'resolutiondate')

    and field_value is not null -- remove initial null rows
),

issue_dates as (

    select

        issue_id,
        min(case when field_id = 'assignee' then updated_at end) as first_assigned_at,
        max(case when field_id = 'assignee' then updated_at end) as last_assigned_at,
        min(case when field_id = 'resolutiondate' then updated_at end) as first_resolved_at -- in case it's been re-opened

    from filtered
    group by 1
)

select *
from issue_dates
