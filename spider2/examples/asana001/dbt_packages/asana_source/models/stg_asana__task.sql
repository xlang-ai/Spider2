
with base as (

    select * 
    from {{ ref('stg_asana__task_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_asana__task_tmp')),
                staging_columns=get_task_columns()
            )
        }}

        --The below script allows for pass through columns.
        {% if var('task_pass_through_columns') %}
        ,
        {{ var('task_pass_through_columns') | join (", ") }}

        {% endif %}

    from base
),

final as (
    
    select 
        id as task_id,
        assignee_id as assignee_user_id,
        completed as is_completed,
        cast(completed_at as {{ dbt.type_timestamp() }}) as completed_at,
        completed_by_id as completed_by_user_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(coalesce(cast(due_on as {{ dbt.type_timestamp() }}), cast(due_at as {{ dbt.type_timestamp() }})) as {{ dbt.type_timestamp() }}) as due_date,
        cast(modified_at as {{ dbt.type_timestamp() }}) as modified_at,
        name as task_name,
        parent_id as parent_task_id,
        cast(start_on as {{ dbt.type_timestamp() }}) as start_date,
        notes as task_description,
        liked as is_liked,
        num_likes as number_of_likes,
        workspace_id

        --The below script allows for pass through columns.
        {% if var('task_pass_through_columns') %}
        ,
        {{ var('task_pass_through_columns') | join (", ") }}

        {% endif %}

    from fields
)

select * 
from final
