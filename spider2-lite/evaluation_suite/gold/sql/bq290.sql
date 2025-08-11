with 

stations_selected as (
  select
    usaf,
    wban,
    country,
    name
  from
    `bigquery-public-data.noaa_gsod.stations`
  where
    country in ('US', 'UK')
),

data_filtered as (
  select
    gsod.*,
    stations.country
  from
    `bigquery-public-data.noaa_gsod.gsod2023` gsod
  join
    stations_selected stations
  on
    gsod.stn = stations.usaf
    and gsod.wban = stations.wban
  where
    date(gsod.date) between '2023-10-01' and '2023-10-31'
    and gsod.temp != 9999.9
),

-- US Metrics
us_metrics as (
  select
    date(date) as metric_date,
    avg(temp) as avg_temp_us,
    min(temp) as min_temp_us,
    max(temp) as max_temp_us
  from
    data_filtered
  where
    country = 'US'
  group by
    metric_date
),

-- UK Metrics
uk_metrics as (
  select
    date(date) as metric_date,
    avg(temp) as avg_temp_uk,
    min(temp) as min_temp_uk,
    max(temp) as max_temp_uk
  from
    data_filtered
  where
    country = 'UK'
  group by
    metric_date
),

-- Temperature Differences
temp_differences as (
  select
    us.metric_date,
    us.max_temp_us - uk.max_temp_uk as max_temp_diff,
    us.min_temp_us - uk.min_temp_uk as min_temp_diff,
    us.avg_temp_us - uk.avg_temp_uk as avg_temp_diff
  from
    us_metrics us
  join
    uk_metrics uk
  on
    us.metric_date = uk.metric_date
)

select 
  metric_date, 
  max_temp_diff, 
  min_temp_diff, 
  avg_temp_diff
from 
  temp_differences
order by
  metric_date;