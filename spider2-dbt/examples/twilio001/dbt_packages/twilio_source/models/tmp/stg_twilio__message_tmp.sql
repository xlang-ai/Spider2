select {{ dbt_utils.star(source('twilio', 'message')) }}
from {{ var('message') }}
