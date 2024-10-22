with

source as (

    select * from {{ source('danish_parliament', 'raw_sagstrin') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as case_step_id,
        folketingstidende as danish_parliament,
        folketingstidendesidenummer as danish_parliament_page_number,
        folketingstidendeurl as danish_parliament_url,
        opdateringsdato as case_step_updated_at,
        sagid as case_id,
        statusid as case_step_status_id,
        titel as case_step_title,
        typeid as case_step_type_id,
        filename as file_name
    from source
)

select * from renamed
