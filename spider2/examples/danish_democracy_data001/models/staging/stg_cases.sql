with

source as (

    select * from {{ source('danish_parliament', 'raw_sag') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as case_id,
        typeid as case_type_id,
        kategoriid as case_category_id,
        statusid as case_status_id,
        titel as case_title,
        titelkort as case_short_title,
        offentlighedskode as case_public_code,
        nummer as case_number,
        nummerprefix as case_number_prefix,
        nummernumerisk as case_number_numeric,
        nummerpostfix as case_number_postfix,
        resume as case_summary,
        afstemningskonklusion as case_voting_conclusion,
        periodeid as case_period_id,
        "afgørelsesresultatkode" as case_decision_result_code,
        baggrundsmateriale as case_background_material,
        opdateringsdato as case_updated_at,
        statsbudgetsag as case_state_budget,
        begrundelse as case_reason,
        paragrafnummer as case_paragraph_number,
        paragraf as case_paragraph,
        "afgørelsesdato" as case_decision_date,
        "afgørelse" as case_decision,
        "rådsmødedato" as case_council_meeting_date,
        lovnummer as case_law_number,
        lovnummerdato as case_law_number_date,
        retsinformationsurl as case_law_url,
        fremsatundersagid as case_proposed_under_case_id,
        deltundersagid as case_shared_case_id
    from source
)

select * from renamed
