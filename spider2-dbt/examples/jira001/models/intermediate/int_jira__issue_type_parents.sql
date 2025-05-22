{{ config(materialized='view') }}
-- needs to be a view to use the dbt_utils.star macro in int_jira__issue_users

with issue as (

    select * 
    from {{ var('issue') }}
    
),

issue_type as (

    select *
    from {{ var('issue_type') }}
), 
-- issue-epic relationships are either captured via the issue's parent_issue_id (next-gen projects)
-- or through the 'Epic Link' field (classic projects)

issues_w_epics as (

    select * 
    from {{ ref('int_jira__issue_epic')}}

), 

issue_enriched_with_epics as (

    select
        issue.*,
        coalesce(cast(parent_issue_id as {{ dbt.type_string() }}), cast(epic_issue_id as {{ dbt.type_string() }})) as revised_parent_issue_id

    from issue
    left join issues_w_epics on issues_w_epics.issue_id = issue.issue_id

), 

issue_w_types as (

    select 
        issue_enriched_with_epics.*,
        issue_type.issue_type_name as issue_type
        
    from issue_enriched_with_epics 
    left join issue_type on issue_type.issue_type_id = issue_enriched_with_epics.issue_type_id
),

add_parent_info as (

    select
        issue_w_types.*,
        parent.issue_type as parent_issue_type,
        parent.issue_name as parent_issue_name,
        parent.issue_key as parent_issue_key,
        lower(coalesce(parent.issue_type, '')) = 'epic' as is_parent_epic

    from issue_w_types
    -- do a left join so we can grab all issue types from this table in `issue_join`
    left join issue_w_types as parent 
        on cast(issue_w_types.revised_parent_issue_id as {{ dbt.type_string() }}) = cast(parent.issue_id as {{ dbt.type_string() }})

)

select * 
from add_parent_info