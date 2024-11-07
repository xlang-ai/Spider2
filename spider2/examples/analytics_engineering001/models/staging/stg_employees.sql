with source as (

    select * from {{ source('northwind', 'employees') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source