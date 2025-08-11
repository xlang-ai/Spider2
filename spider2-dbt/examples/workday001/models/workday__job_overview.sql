with job_profile_data as (

    select * 
    from {{ ref('stg_workday__job_profile') }}
),


job_family_profile_data as (

    select 
        job_family_id,
        job_profile_id,
        source_relation
    from {{ ref('stg_workday__job_family_job_profile') }}
),

job_family_data as (

    select 
        job_family_id,
        source_relation,
        job_family_code,
        job_family_summary
    from {{ ref('stg_workday__job_family') }}
),

job_family_job_family_group_data as (

    select 
        job_family_group_id,
        job_family_id,
        source_relation
    from {{ ref('stg_workday__job_family_job_family_group') }}
),

job_family_group_data as (

    select 
        job_family_group_id,
        source_relation,
        job_family_group_code,
        job_family_group_summary
    from {{ ref('stg_workday__job_family_group') }}
),

job_data_enhanced as (

    select
        job_profile_data.job_profile_id,
        job_profile_data.source_relation,
        job_profile_data.job_profile_code, 
        job_profile_data.job_title,
        job_profile_data.private_title,
        job_profile_data.job_summary,
        job_profile_data.job_description,
        {{ fivetran_utils.string_agg('distinct job_family_data.job_family_code', "', '" ) }} as job_family_codes,
        {{ fivetran_utils.string_agg('distinct job_family_data.job_family_summary', "', '" ) }} as job_family_summaries, 
        {{ fivetran_utils.string_agg('distinct job_family_group_data.job_family_group_code', "', '" ) }} as job_family_group_codes,
        {{ fivetran_utils.string_agg('distinct job_family_group_data.job_family_group_summary', "', '" ) }} as job_family_group_summaries

    from job_profile_data 
    left join job_family_profile_data 
        on job_profile_data.job_profile_id = job_family_profile_data.job_profile_id
        and job_profile_data.source_relation = job_family_profile_data.source_relation
    left join job_family_data
        on job_family_profile_data.job_family_id = job_family_data.job_family_id
        and job_family_profile_data.source_relation = job_family_data.source_relation
    left join job_family_job_family_group_data
        on job_family_job_family_group_data.job_family_id = job_family_data.job_family_id
        and job_family_job_family_group_data.source_relation = job_family_data.source_relation
    left join job_family_group_data 
        on job_family_job_family_group_data.job_family_group_id = job_family_group_data.job_family_group_id
        and job_family_job_family_group_data.source_relation = job_family_group_data.source_relation
    {{ dbt_utils.group_by(7) }}
)

select *
from job_data_enhanced 