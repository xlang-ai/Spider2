with job_office as (

    select *
    from {{ ref('stg_greenhouse__job_office') }}
),

office as (

    select *
    from {{ ref('stg_greenhouse__office') }}
),

agg_offices as (

    select
        job_id,
        {{ fivetran_utils.string_agg("office.office_name", "'; '") }} as offices,
        {{ fivetran_utils.string_agg("office.location_name", "'; '") }} as locations

    from job_office
    join office using(office_id)

    group by job_id
)

select * from 
agg_offices