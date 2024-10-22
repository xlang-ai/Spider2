select
    -- identifiers
    {{ dbt_utils.generate_surrogate_key(['TATZEIT_ANFANG', 'TATZEIT_ENDE', 'LOR', 'SCHADENSHOEHE', 'ART_DES_FAHRRADS']) }} as record_id,
    cast(LOR as integer) as plr_id,
    
    -- timestamps
    TATZEIT_ANFANG  as crime_period_start_datetime,
    TATZEIT_ENDE    as crime_period_end_datetime,
    ANGELEGT_AM     as record_created,
    TATZEIT_DAUER   as crime_period_duration,
    -- cast(DATE(TATZEIT_ANFANG))  as crime_period_start_date,
    -- cast(DATE(TATZEIT_ENDE))  as crime_period_end_date,
    -- cast(YEAR(TATZEIT_ANFANG))  as crime_period_start_year,
    -- cast(MONTH(TATZEIT_ANFANG))  as crime_period_start_month,
    -- cast(HOUR(TATZEIT_ANFANG))  as crime_period_start_hour,
    -- cast(WEEKDAY(TATZEIT_ANFANG)) as crime_period_start_weekday,
    
    -- theft info
    SCHADENSHOEHE as  damage_euro,
    ART_DES_FAHRRADS as bike_type

from {{ source('main','reported_incidents_archived') }}
