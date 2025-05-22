with issue as (

    select *
    from {{ ref('int_jira__issue_join' ) }}
),

{%- set pivot_data_columns = adapter.get_columns_in_relation(ref('jira__daily_issue_field_history')) -%}

{%- set issue_data_columns = adapter.get_columns_in_relation(ref('int_jira__issue_join' )) -%}
{%- set issue_data_columns_clean = [] -%}

{%- for k in issue_data_columns -%}
    {{ issue_data_columns_clean.append(k.name|lower)|default("", True)  }}
{%- endfor -%}

daily_issue_field_history as (
    
    select
        *,
        row_number() over (partition by issue_id order by date_day desc) = 1 as latest_record
    from {{ ref('jira__daily_issue_field_history')}}

),

latest_issue_field_history as (
    
    select
        *
    from daily_issue_field_history
    where latest_record
),

final as (

    select 
    
        issue.*,

        {{ dbt.datediff('created_at', "coalesce(resolved_at, " ~ dbt.current_timestamp_backcompat() ~ ')', 'second') }} open_duration_seconds,

        -- this will be null if no one has been assigned
        {{ dbt.datediff('first_assigned_at', "coalesce(resolved_at, " ~ dbt.current_timestamp_backcompat() ~ ')', 'second') }} any_assignment_duration_seconds,

        -- if an issue is not currently assigned this will not be null
        {{ dbt.datediff('last_assigned_at', "coalesce(resolved_at, " ~ dbt.current_timestamp_backcompat() ~ ')', 'second') }} last_assignment_duration_seconds 

        {% for col in pivot_data_columns if col.name|lower not in issue_data_columns_clean %} 
            {%- if col.name|lower not in ['issue_day_id','issue_id','latest_record', 'date_day'] -%}
                , {{ col.name }}
            {%- endif -%}
        {% endfor %}

    from issue
    
    left join latest_issue_field_history 
        on issue.issue_id = latest_issue_field_history.issue_id
        
)

select *
from final