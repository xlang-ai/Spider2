select {{ dbt_utils.star(source('twilio', 'account_history')) }}
from {{ var('account_history') }}
