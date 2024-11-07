with lever_user as (
    select *
    from {{ var('user') }}
),

opportunity_application as (
    
    select *
    from {{ ref('int_lever__opportunity_application') }}
),

-- necessary users = opp owner, referrer, hiring manager
grab_user_names as (

    select
        opportunity_application.*,
        opportunity_owner.full_name as opportunity_owner_name,
        referrer.full_name as referrer_name,
        hiring_manager.full_name as hiring_manager_name

    from opportunity_application

    left join lever_user as opportunity_owner
        on opportunity_application.owner_user_id = opportunity_owner.user_id
    left join lever_user as referrer
        on opportunity_application.referrer_user_id = referrer.user_id 
    left join lever_user as hiring_manager
        on opportunity_application.posting_hiring_manager_user_id = hiring_manager.user_id
)

select * from grab_user_names