select x.*  from {{ source('asset_mgmt', 'trades') }} x
