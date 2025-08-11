with

source as (

    select * from {{ source('danish_parliament', 'raw_afstemning') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as vote_id,
        nummer as vote_number,
        konklusion as conclusion,
        vedtaget as approved,
        kommentar as vote_comment,
        "mødeid" as meeting_id,
        typeid as voting_type_id,
        sagstrinid as case_step_id,
        opdateringsdato as votes_updated_at,
        filename as file_name
    from source
)

select * from renamed
