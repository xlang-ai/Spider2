with raw_airports as (

    select * from {{ source('raw', 'raw_airports') }}

),

cleaned as (

    select
        airport_id,
        {{ rm_quotes('name')}},
        {{ rm_quotes('city')}},
        {{ rm_quotes('country')}},
        {{ rm_quotes('iata')}},
        {{ rm_quotes('icao')}},
        latitude,
        longitude,
        altitude,
        {{ rm_quotes('timezone')}},
        {{ rm_quotes('dst')}},
        {{ rm_quotes('database_time_zone')}},
        {{ rm_quotes('type')}},
        {{ rm_quotes('source')}}

    from
        raw_airports

)

select * from cleaned