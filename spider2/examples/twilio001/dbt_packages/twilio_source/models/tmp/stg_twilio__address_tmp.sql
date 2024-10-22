select {{ dbt_utils.star(source('twilio', 'address')) }}
from {{ var('address') }}
