with source as (
    select * from {{ source('main', 'raw_allo_deployments') }}
),

renamed as (
    select
        lower(address) as address,
        chain_name,
        lower(contract) as contract
    from source
)

select * from renamed
