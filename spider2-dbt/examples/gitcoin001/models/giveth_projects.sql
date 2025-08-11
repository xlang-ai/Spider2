with source as (
    select * from {{ source('main', 'raw_giveth_projects') }}
),

renamed as (
    select
        title,
        totalDonations as total_donations,
        totalTraceDonations as total_trace_donations
    from source
)

select * from renamed
