with source as (
    select * from {{ source('main', 'raw_karmahq_attestations') }}
),

renamed as (
    select
        lower(attester) as attester,
        lower(recipient) as recipient,
        isOffchain as is_offchain,
        decodedDataJson as decoded_data_json
    from source
)

select * from renamed
