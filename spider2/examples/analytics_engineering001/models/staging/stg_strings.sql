with source as (

    select * from {{ source('northwind', 'strings') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source
