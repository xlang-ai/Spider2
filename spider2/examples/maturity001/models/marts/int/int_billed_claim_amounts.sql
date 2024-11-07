with 

claim_lines as (
    select * from {{ ref('stg_claim_lines')}}
),

final as (
    
    select 
        claim_lines.claim_id, 
        sum(charge_amount) as total_charge_amount,
        sum(paid_amount) as total_paid_amount,
        sum(error_amount) as total_error_amount
    
    from claim_lines
    
    where status in ('billed', 'adjudicated', 'closed')
    
    group by 1

)

select * from final