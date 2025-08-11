select company from
            (select *,
            row_number() over(partition by company order by month_o_month_calc desc) as rownum
            from
            (select *,
            num_trips - lag(num_trips) over(partition by company order by month) as month_o_month_calc
                from
                (SELECT 
                company,
                format_date("%Y-%m", date_sub((cast(trip_start_timestamp as date)), interval 1 month)) as prev_month,
                format_date("%Y-%m", cast(trip_start_timestamp as date)) AS month,
                count(1) AS num_trips
                from `bigquery-public-data.chicago_taxi_trips.taxi_trips`
                where extract(YEAR from trip_start_timestamp) = 2018
                group by company, month, prev_month
                order by company,month)
            order by company, month_o_month_calc desc)
            ) 
        where rownum = 1
        order by month_o_month_calc desc, company 
        limit 3