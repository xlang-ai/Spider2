
select 
    title
  , premiere_date
  , premiere_status
  , genre 
  , category
  , seasons
  , runtime
  , renewal_status
  , premiere_year
  , premiere_month
  , premiere_day
  , updated_at_utc
from {{ ref('int_netflix_original_programs') }}