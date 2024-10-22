with source as (
    select * from {{ source('main', 'raw_chain_metadata') }}
),

renamed as (
    select
        name,
        shortName as short_name,
        infoURL as info_url,
        chainId as chain_id,
        networkId as network_id,
        nativeCurrency as native_currency,
        ens,
        explorers,
        rpc,
        parent
    from source
)

select * from renamed
