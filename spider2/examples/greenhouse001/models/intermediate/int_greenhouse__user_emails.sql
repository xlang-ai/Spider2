with user_email as (
    select *
    from {{ ref('stg_greenhouse__user_email') }}
),

greenhouse_user as (
    select *
    from {{ ref('stg_greenhouse__user') }}
),

agg_emails as (
    select
        user_id,
        listagg(email, ', ') as email  -- 使用 DuckDB 的 listagg 替代 list_agg
    from user_email 
    group by user_id
),

final as (
    select 
        greenhouse_user.*,
        agg_emails.email
    from 
    greenhouse_user
    left join agg_emails
    on greenhouse_user.user_id = agg_emails.user_id  -- 使用 ON 替代 USING
)

select * 
from final
