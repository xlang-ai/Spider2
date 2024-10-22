with source as (
    select * from {{ source('main', 'raw_gitcoin_passport_scores') }}
),

renamed as (
    select
        id,
        passport ->> 'address' as address,
        passport ->> 'community' as community,
        score,
        last_score_timestamp,
        status,
        error,
        evidence ->> 'type' as evidence_type,
        evidence ->> 'success' as evidence_success,
        evidence ->> 'rawScore' as evidence_raw_score,
        evidence ->> 'threshold' as evidence_threshold,
        stamp_scores
    from source
)

select * from renamed order by last_score_timestamp desc
