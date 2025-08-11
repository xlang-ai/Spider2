{{ config(
    tags=["mart", "dimension"]
  )
}}

with date_spine as (
  {{ dbt_utils.date_spine(
      datepart="day",
      start_date="cast('1800-01-01' as date)",
      end_date="cast('2025-07-01' as date)"
    )
  }}
)
, ref_unknown_record as (
	select *
	  from {{ ref('ref_unknown_values') }}
)
, calendar as (
  select {{ to_date_key('date_day') }} as dim_date_key
        ,date_day
        ,{{ to_iso_date('date_day') }} as date_iso
        ,{{ to_date_gb('date_day') }} as date_gb
        ,{{ to_date_us('date_day') }} as date_us
        ,strftime(date_day, '%A') as day_of_week
        ,isodow(date_day) as day_of_week_number
        ,strftime(date_day, '%a') as day_of_week_abbr
        ,strftime(date_day, '%d') as day_of_month
        ,strftime(date_day, '%-d') as day_of_month_number
        ,strftime(date_day, '%j') as day_of_year
        ,strftime(date_day, '%W') as week_of_year
        ,strftime(date_day, '%m') as month_of_year
        ,strftime(date_day, '%B') as month_name
        ,strftime(date_day, '%b') as month_name_abbr
        ,strftime(date_day, '%Y-%m-01') as first_day_of_month
        ,last_day(date_day) as last_day_of_month
        ,'Q'||date_part('quarter', date_day) as quarter_of_year
        ,strftime(date_day, '%Y') as year
        ,'C'||strftime(date_day, '%y') as year_abbr
        ,date_diff('day', strftime(now(), '%Y-%m-%d')::date, date_day) as day_offset
        ,date_diff('week', strftime(now(), '%Y-%m-%d')::date, date_day) as week_offset
        ,date_diff('month', strftime(now(), '%Y-%m-%d')::date, date_day) as month_offset
        ,date_diff('quarter', strftime(now(), '%Y-%m-%d')::date, date_day) as quarter_offset
        ,date_diff('year', strftime(now(), '%Y-%m-%d')::date, date_day) as year_offset
        ,date_day - interval 7 day as same_day_last_week
        ,date_day - interval 14 day as same_day_last_fortnight
        ,date_day - interval 1 month as same_day_last_month
        ,date_day - interval 1 year as same_day_last_year
        ,date_day + interval 7 day as same_day_next_week
        ,date_day + interval 14 day as same_day_next_fortnight
        ,date_day + interval 1 month as same_day_next_month
        ,date_day + interval 1 year as same_day_next_year
        ,'Q'||date_part('quarter', date_day + interval 6 month) as fiscal_quarter_of_year
        ,strftime(date_day + interval 6 month, '%Y') as fiscal_year
        ,'F'||strftime(date_day + interval 6 month, '%y') as fiscal_year_abbr
    from date_spine
)
, unknown_record as (
    select dim_date_key
          ,date_day
          ,date_iso
          ,date_gb
          ,date_us
          ,day_of_week_number
          ,day_of_week
          ,day_of_week_abbr
          ,day_of_month
          ,day_of_month_number
          ,case 
              when day_of_month_number in (1, 21, 31) then 'st'
              when day_of_month_number in (2, 22) then 'nd'
              when day_of_month_number in (3, 23) then 'rd'
              else 'th'
           end as day_ordinal_indicator
          ,day_of_year
          ,week_of_year
          ,month_of_year
          ,month_name
          ,month_name_abbr
          ,month_of_year||' '||month_name_abbr as month_numbered
          ,first_day_of_month
          ,last_day_of_month
          ,quarter_of_year||' '||year_abbr as quarter
          ,quarter_of_year
          ,year
          ,year_abbr
          ,day_offset
          ,week_offset
          ,month_offset
          ,quarter_offset
          ,year_offset
          ,same_day_last_week
          ,same_day_last_fortnight
          ,same_day_last_month
          ,same_day_last_year
          ,same_day_next_week
          ,same_day_next_fortnight
          ,same_day_next_month
          ,same_day_next_year
          ,fiscal_quarter_of_year||' '||fiscal_year_abbr as fiscal_quarter
          ,fiscal_quarter_of_year
          ,fiscal_year
          ,fiscal_year_abbr
      from calendar

    union all
    
    select unknown_key as dim_date_key
          ,unknown_null as date_day
          ,unknown_text as date_iso
          ,unknown_text as date_gb
          ,unknown_text as date_us
          ,unknown_integer as day_of_week_number
          ,unknown_text as day_of_week
          ,unknown_text as day_of_week_abbr
          ,unknown_text as day_of_month
          ,unknown_integer as day_of_month_number
          ,unknown_text as day_ordinal_indicator
          ,unknown_text as day_of_year
          ,unknown_text as week_of_year
          ,unknown_text as month_of_year
          ,unknown_text as month_name
          ,unknown_text as month_name_abbr
          ,unknown_text as month_numbered
          ,unknown_date as first_day_of_month
          ,unknown_date as last_day_of_month
          ,unknown_text as quarter
          ,unknown_text as quarter_of_year
          ,unknown_integer as year
          ,unknown_text as year_abbr
          ,unknown_null as day_offset
          ,unknown_null as week_offset
          ,unknown_null as month_offset
          ,unknown_null as quarter_offset
          ,unknown_null as year_offset
          ,unknown_date as same_day_last_week
          ,unknown_date as same_day_last_fortnight
          ,unknown_date as same_day_last_month
          ,unknown_date as same_day_last_year
          ,unknown_date as same_day_next_week
          ,unknown_date as same_day_next_fortnight
          ,unknown_date as same_day_next_month
          ,unknown_date as same_day_next_year
          ,unknown_text as fiscal_quarter
          ,unknown_text as fiscal_quarter_of_year
          ,unknown_integer as fiscal_year
          ,unknown_text as fiscal_year_abbr
      from ref_unknown_record
)
select *
  from unknown_record