with 

claim_diagnoses as (
    select * from {{ ref('stg_claim_diagnosis') }}
),

final as (

    select 
        claim_id,
        {{ pivot_claim_diagnoses(3) }}
    from claim_diagnoses

    group by 1


)

select * from final