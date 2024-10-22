with source as (

    select * from {{ source('northwind', 'invoices') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source
