with job_department as (

    select *
    from {{ ref('stg_greenhouse__job_department') }}
),

department as (

    select *
    from {{ ref('stg_greenhouse__department') }}
),

join_parent_department as (

    select 
        sub.*,
        parent.name as parent_department_name

    from department as sub 
        left join department as parent on sub.parent_department_id = parent.department_id
),

agg_departments as (

    select
        job_id,
        {{ fivetran_utils.string_agg("join_parent_department.name", "'; '") }} as departments,
        {{ fivetran_utils.string_agg("join_parent_department.parent_department_name", "'; '") }} as parent_departments

    from job_department
    join join_parent_department using(department_id)

    group by job_id
)

select * from 
agg_departments