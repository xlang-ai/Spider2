with source as (

    select * from {{ source('northwind', 'inventory_transaction_types') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source