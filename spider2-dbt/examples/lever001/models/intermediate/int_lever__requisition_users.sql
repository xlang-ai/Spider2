{{ config(enabled=var('lever_using_requisitions', True)) }}

with lever_user as (

    select *
    from {{ var('user') }}
),

requisition as (
    
    select *
    from {{ var('requisition') }}
),

-- necessary users = req owner, creator, hiring manager
grab_user_names as (

    select
        requisition.*,
        creator.full_name as creator_name,
        requisition_owner.full_name as requisition_owner_name,
        hiring_manager.full_name as hiring_manager_name

    from requisition

    left join lever_user as creator
        on requisition.creator_user_id = creator.user_id

    left join lever_user as hiring_manager
        on requisition.hiring_manager_user_id = hiring_manager.user_id

    
    left join lever_user as requisition_owner
        on requisition.owner_user_id = requisition_owner.user_id

)

select * from grab_user_names