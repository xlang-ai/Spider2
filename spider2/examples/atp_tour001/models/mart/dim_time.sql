{{ config(
    tags=["mart", "dimension"]
  )
}}

with recursive num_of_minutes as (
  select 0 as minute_num

    union all

  select minute_num + 1
    from num_of_minutes
   where minute_num < (60 * 24) - 1
)
, ref_unknown_record as (
	select *
	  from {{ ref('ref_unknown_values') }}
)
, time_series as (
  select minute_num
		    ,to_minutes(minute_num) as this_minute
    from num_of_minutes
)
, renamed as (
  select strftime(('1900-01-01 ' || this_minute)::timestamp, '%H%M')::int as dim_time_key
        ,this_minute as the_time
        ,minute_num as num_of_minutes
        ,extract('hour' from this_minute) + 1 as the_hour
        ,extract('minute' from this_minute) + 1 as the_minute
        ,extract('hour' from this_minute) as military_hour
        ,extract('minute' from this_minute) as military_minute
        ,case
            when this_minute < '12:00:00' then 'AM'
            else 'PM'
         end::varchar as am_pm
        ,case
            when this_minute >= '00:00:00' and this_minute < '06:00:00' then 'Night'
            when this_minute >= '06:00:00' and this_minute < '12:00:00' then 'Morning'
            when this_minute >= '12:00:00' and this_minute < '18:00:00' then 'Afternoon'
            else 'Evening'
         end::varchar as time_of_day
        ,case
            when this_minute >= '13:00:00' then this_minute - interval 12 hours
            else this_minute
         end::varchar as notation_12
        ,this_minute::varchar as notation_24
    from time_series
)
, unknown_record as (
  select unknown_key::int as dim_time_key
        ,null::interval as the_time
        ,unknown_text::varchar as standard_time
        ,unknown_integer::int as num_of_minutes
        ,unknown_integer::int as the_hour
        ,unknown_integer::int as the_minute
        ,unknown_integer::int as military_hour
        ,unknown_integer::int as military_minute
        ,unknown_text::varchar as am_pm
        ,unknown_text::varchar as time_of_day
        ,unknown_text::varchar as notation_12
        ,unknown_text::varchar as notation_24
    from ref_unknown_record

  union all

  select dim_time_key
        ,the_time
        ,notation_12||' '||am_pm as standard_time
        ,num_of_minutes
        ,the_hour
        ,the_minute
        ,military_hour
        ,military_minute
        ,am_pm
        ,time_of_day
        ,notation_12
        ,notation_24
    from renamed
)
select *
  from unknown_record