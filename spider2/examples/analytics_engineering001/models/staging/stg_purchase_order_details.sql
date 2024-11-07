with source as (

    select * from {{ source('northwind', 'purchase_order_details') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source
