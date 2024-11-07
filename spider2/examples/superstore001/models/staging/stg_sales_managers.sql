select
     person as manager_name
    ,region

from {{ source('superstore', 'sales_managers') }}