with

source as (

    select * from {{ source('danish_parliament', 'raw_aktoer') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1
),

renamed as (

    select
        id as actor_id,
        typeid as actor_type_id,
        gruppenavnkort as group_short_name,
        navn as full_name,
        fornavn as first_name,
        efternavn as last_name,
        biografi as biography,
        periodeid as period_id,
        opdateringsdato as updated_at,
        startdato as valid_from,
        slutdato as valid_to,
        filename as file_name,
        substring(
            biografi,
            position('<sex>' in biografi) + length('<sex>'),
            position('</sex>' in biografi)
            - position('<sex>' in biografi)
            - length('<sex>')
        ) as gender,
        try_strptime(substring(
            biografi,
            position('<born>' in biografi) + length('<born>'),
            position('</born>' in biografi)
            - position('<born>' in biografi)
            - length('<born>')
        ), '%d-%m-%Y') as birth_date,
        try_strptime(substring(
            biografi, position('<died>' in biografi) + length('<died>'),
            position('</died>' in biografi)
            - position('<died>' in biografi)
            - length('<died>')
        ), '%d-%m-%Y') as death_date,
        substring(
            biografi,
            position('<party>' in biografi) + length('<party>'),
            position('</party>' in biografi)
            - position('<party>' in biografi)
            - length('<party>')
        ) as party_name,
        substring(
            biografi,
            position('<partyShortname>' in biografi)
            + length('<partyShortname>'),
            position('</partyShortname>' in biografi)
            - position('<partyShortname>' in biografi)
            - length('<partyShortname>')
        ) as party_short_name
    from source

)

select * from renamed
