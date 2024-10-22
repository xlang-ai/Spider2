with source as (
    select * from {{ source('main', 'raw_allo_donations') }}
),

renamed as (
    select
        amountInUsd as amount_in_usd,
        amount,
        amountInRoundMatchToken as amount_in_round_match_token,
        applicationId as application_id,
        blockNumber as block_number,
        chainId as chain_id,
        lower(id) as id,
        lower(donorAddress) as donor_address,
        nodeId as node_id,
        lower(projectId) as project_id,
        lower(recipientAddress) as recipient_address,
        lower(roundId) as round_id,
        lower(tokenAddress) as token_address,
        lower(transactionHash) as transaction_hash,
    from source
)

select * from renamed
