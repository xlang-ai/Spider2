select {{ dbt_utils.star(source('twilio', 'usage_record')) }}
from {{ var('usage_record') }}
