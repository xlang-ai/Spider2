with raw_arrivals as (

    select * from {{ source('raw', 'raw_arrivals') }}

),

renamed_n_cast_n_add_col as (

    select
        sorttime                                        as sort_time_utc,
        sorttime + interval '8 hour'                    as arrival_timestamp,
        operatedby                                      as operated_by,
        concat('https://www.flightstats.com/v2', url)   as full_url,
        strptime("date", '%d-%b-%Y')                    as arrival_date,
        iata                                            as arrival_iata,
        icao                                            as arrival_icao,
        airport_name                                    as arrival_airport_name,
        departuretime_timeampm                          as departure_time_time_am_pm,
        departuretime_time24                            as departure_time_time_24,
        arrivaltime_timeampm                            as arrival_time_time_am_pm,
        arrivaltime_time24                              as arrival_time_time_24,
        carrier_fs                                      as carrier_fs,
        carrier_name                                    as carrier_name,
        carrier_flightnumber                            as carrier_flight_number,
        airport_fs                                      as departure_airport_fs,
        airport_city                                    as departure_airport_city,
        iscodeshare                                     as is_code_share

    from
        raw_arrivals

)

select * from renamed_n_cast_n_add_col

