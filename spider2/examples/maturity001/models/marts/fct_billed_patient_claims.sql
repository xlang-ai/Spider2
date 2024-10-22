{{
  config(
    materialized = 'incremental',
    unique_key = 'claim_id',
    )
}}

with 

claims as (
    select * from {{ ref('stg_claims') }}
    {% if is_incremental() %}
      where stg_claims.created_at >= (select max(created_at) from {{ this }})
    {% endif %}

),

claim_charge_amounts as (
    select * from {{ ref('int_billed_claim_amounts') }}
),

claim_diagnoses as (
    select * from {{ ref('int_claim_diagnosis_pivoted') }}
),

final as (

    select 
        claims.claim_id,
        claims.patient_id,
        claims.doctor_id,
        claim_diagnoses.diagnosis_1,
        claim_diagnoses.diagnosis_description_1,
        claim_diagnoses.diagnosis_2,
        claim_diagnoses.diagnosis_description_2,
        claims.carrier_claim_number,
        claim_charge_amounts.total_charge_amount,
        claim_charge_amounts.total_paid_amount,
        claims.created_at,
        claims.first_billed_at
    from 
        claims
        left join claim_charge_amounts
            on claims.claim_id = claim_charge_amounts.claim_id
        left join claim_diagnoses
            on claims.claim_id = claim_diagnoses.claim_id
    
    where claims.has_ever_been_billed

)

select * from final
