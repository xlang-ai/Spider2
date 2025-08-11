with source as (
      select * from {{ source('main', 'raw_allo_subscriptions') }}
),

renamed as (
    select
        chainId as chain_id,
        lower(contractAddress) as contract_address,
        contractName as contract_name,
        createdAt as created_at,
        fromBlock as from_block,
        id,
        indexedToBlock as indexed_to_block,
        indexedToLogIndex as indexed_to_log_index,
        nodeId as node_id,
        toBlock as to_block,
        updatedAt as updated_at
    from source
)

select * from renamed
