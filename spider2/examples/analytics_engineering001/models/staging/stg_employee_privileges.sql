with source as (

    select * from {{ source('northwind', 'employee_privileges') }}
)
select
    *,
    get_current_timestamp() as ingestion_timestamp
from source