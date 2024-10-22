select {{ dbt_utils.star(source('twilio', 'outgoing_caller_id')) }}
from {{ var('outgoing_caller_id') }}
