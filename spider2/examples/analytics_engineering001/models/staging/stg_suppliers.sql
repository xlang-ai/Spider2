with source as (

    select * from {{ source('northwind', 'suppliers') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source
