with sessions as (
    select * from {{ source('playbook','sessions') }}
),

customer_conversions as (
    select * from {{ source('playbook','customer_conversions') }}
),

sessions_before_conversion as (
    select
        sessions.*,
        customer_conversions.converted_at,
        customer_conversions.revenue,
        count(*) over (partition by sessions.customer_id) as total_sessions,
        row_number() over (partition by sessions.customer_id order by sessions.started_at) as session_index
    from sessions
    left join customer_conversions on sessions.customer_id = customer_conversions.customer_id
    where sessions.started_at <= customer_conversions.converted_at
        and sessions.started_at >= customer_conversions.converted_at - INTERVAL '30 days'
),

with_points as (
    select
        *,
        case
            when session_index = 1 then 1.0
            else 0.0
        end as first_touch_points,
        case
            when session_index = total_sessions then 1.0
            else 0.0
        end as last_touch_points,
        case
            when total_sessions = 1 then 1.0
            when total_sessions = 2 then 0.5
            when session_index = 1 then 0.4
            when session_index = total_sessions then 0.4
            else 0.2 / (total_sessions - 2)
        end as forty_twenty_forty_points,
        1.0 / total_sessions as linear_points,
        revenue * (case when session_index = 1 then 1.0 else 0.0 end) as first_touch_revenue,
        revenue * (case when session_index = total_sessions then 1.0 else 0.0 end) as last_touch_revenue,
        revenue * (case
            when total_sessions = 1 then 1.0
            when total_sessions = 2 then 0.5
            when session_index = 1 then 0.4
            when session_index = total_sessions then 0.4
            else 0.2 / (total_sessions - 2)
        end) as forty_twenty_forty_revenue,
        revenue * (1.0 / total_sessions) as linear_revenue
    from sessions_before_conversion
)

select * from with_points
