select {{ dbt_utils.star(source('twilio', 'incoming_phone_number')) }}
from {{ var('incoming_phone_number') }}
