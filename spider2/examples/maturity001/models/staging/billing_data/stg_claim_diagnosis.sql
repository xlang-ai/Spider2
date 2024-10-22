with 

source as (
    select * from {{ source('billing_data', 'claim_diagnosis') }} 
),

renamed as (

    select 
        id as claim_diagnosis_id,
        claim_id as claim_id,

        -- numbers
        pos as diagnosis_number,

        -- varchsrs
        icd10 as icd_10_code,
        split_part(icd10, '.', 1) as parent_icd10,
        icd10desc as icd_10_code_descrip,

        -- dates
        created as created_at,
        _fivetran_synced_at as _fivetran_synced_at

    
    from source

)

select * from renamed
