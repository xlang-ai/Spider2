with source as (

    select * from {{ source('northwind', 'purchase_orders') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source
