with source as (
    select * from {{ source('main', 'raw_allo_rounds') }}
),

renamed as (
    select
        adminRole as admin_role,
        applicationMetadata as application_metadata,
        applicationMetadataCid as application_metadata_cid,
        applicationsEndTime as applications_end_time,
        applicationsStartTime as applications_start_time,
        chainId as chain_id,
        createdAtBlock as created_at_block,
        createdByAddress as created_by_address,
        donationsEndTime as donations_end_time,
        donationsStartTime as donations_start_time,
        lower(id) as id,
        managerRole as manager_role,
        matchAmount as match_amount,
        matchAmountInUsd as match_amount_in_usd,
        matchTokenAddress as match_token_address,
        nodeId as node_id,
        lower(projectId) as project_id,
        roundMetadata as round_metadata,
        roundMetadataCid as round_metadata_cid,
        roundMetadata->>'$.name' as round_metadata_name,
        roundMetadata->>'$.roundType' as round_metadata_round_type,
        lower(roundMetadata->>'$.programContractAddress') as round_metadata_program_address,
        roundMetadata->>'$.quadraticFundingConfig.sybilDefense' as round_metadata_sybil_defense,
        strategyAddress as strategy_address,
        strategyId as strategy_id,
        strategyName as strategy_name,
        tags,
        totalAmountDonatedInUsd as total_amount_donated_in_usd,
        totalDonationsCount as total_donations_count,
        uniqueDonorsCount as unique_donors_count,
        updatedAtBlock as updated_at_block
    from source
)

select * from renamed
