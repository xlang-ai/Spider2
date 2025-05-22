with source as (

    select * from {{ source('northwind', 'orders') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source
