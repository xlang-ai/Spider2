with task_project as (

    select *
    from {{ var('project_task') }}

),

project as (

    select *
    from {{ var ('project') }}
),

task_section as (

    select *
    from {{ var('task_section') }}

),

section as (

    select *
    from {{ var ('section') }}

),

task_project_section as (

    select
        task_project.task_id,
        project.project_name || (case when section.section_name = '(no section)' then ''
            else ': ' || section.section_name end) as project_section,
        cast(project.project_id as {{ dbt.type_string() }}) as project_id,
        project.project_name
    from
    task_project
    join project
        on project.project_id = task_project.project_id
    join task_section
        on task_section.task_id = task_project.task_id
    join section
        on section.section_id = task_section.section_id
        and section.project_id = project.project_id
),

agg_project_sections as (
    select
        task_id,
        {{ fivetran_utils.string_agg( 'task_project_section.project_section', "', '" )}} as projects_sections,
        {{ fivetran_utils.string_agg( 'task_project_section.project_id', "', '" )}} as project_ids,
        {{ fivetran_utils.string_agg( 'task_project_section.project_name', "', '" )}} as project_names,
        count(project_id) as number_of_projects

    from task_project_section

    group by 1
)

select * from agg_project_sections
