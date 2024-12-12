with guide as (

    select *
    from {{ ref('int_pendo__latest_guide') }}
),

guide_step as (

    select *
    from {{ ref('int_pendo__latest_guide_step') }}
),

agg_guide_steps as (

    select 
        guide_id,
        count(distinct step_id) as count_steps

    from guide_step 
    group by 1
),

application as (

    select *
    from {{ ref('int_pendo__latest_application') }}
),

pendo_user as (

    select *
    from {{ var('user') }}
),

guide_join as (

    select
        guide.*,
        application.display_name as app_display_name,
        application.platform as app_platform,
        creator.first_name || ' ' || creator.last_name as created_by_user_full_name,
        creator.username as created_by_user_username,
        updater.first_name || ' ' || updater.last_name as last_updated_by_user_full_name,
        updater.username as last_updated_by_user_username,
        agg_guide_steps.count_steps

    from guide
    left join agg_guide_steps
        on guide.guide_id = agg_guide_steps.guide_id
    left join application 
        on guide.app_id = application.application_id
    left join pendo_user as creator
        on guide.created_by_user_id = creator.user_id
    left join pendo_user as updater
        on guide.last_updated_by_user_id = updater.user_id
)

select *
from guide_join