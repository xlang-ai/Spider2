select
     distinct order_id

from {{ source('superstore', 'returned_orders') }}