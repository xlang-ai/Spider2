with source as (

    select * from {{ source('northwind', 'inventory_transactions') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source