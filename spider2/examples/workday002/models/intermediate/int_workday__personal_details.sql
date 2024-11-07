with worker_personal_info_data as(

    select 
        worker_id, 
        source_relation,
        date_of_birth,
        gender,
        is_hispanic_or_latino
    from {{ ref('stg_workday__personal_information') }}
),

worker_name as (

    select 
        worker_id, 
        source_relation,
        first_name,
        last_name
    from {{ ref('stg_workday__person_name') }}
    where lower(person_name_type) = 'preferred'
),

worker_email as(

    select 
        worker_id,
        source_relation,
        email_address
    from {{ ref('stg_workday__person_contact_email_address') }}
    where lower(email_code) like '%work_primary%'
),

worker_ethnicity as (

    select 
        worker_id,
        source_relation,
        {{ fivetran_utils.string_agg('distinct ethnicity_code', "', '" ) }} as ethnicity_codes
    from {{ ref('stg_workday__personal_information_ethnicity') }}
    group by 1, 2
),

worker_military as (

    select 
        worker_id,
        source_relation,
        true as is_military_service,
        military_status 
    from {{ ref('stg_workday__military_service') }}
),

worker_personal_details as (

    select 
        worker_personal_info_data.*,
        worker_name.first_name,
        worker_name.last_name,
        worker_email.email_address,
        worker_ethnicity.ethnicity_codes,
        worker_military.military_status
    from worker_personal_info_data
    left join worker_name 
        on worker_personal_info_data.worker_id = worker_name.worker_id
        and worker_personal_info_data.source_relation = worker_name.source_relation
    left join worker_email 
        on worker_personal_info_data.worker_id = worker_email.worker_id
        and worker_personal_info_data.source_relation = worker_email.source_relation
    left join worker_ethnicity 
        on worker_personal_info_data.worker_id = worker_ethnicity.worker_id
        and worker_personal_info_data.source_relation = worker_ethnicity.source_relation
    left join worker_military
        on worker_personal_info_data.worker_id = worker_military.worker_id
        and worker_personal_info_data.source_relation = worker_military.source_relation
)

select * 
from worker_personal_details