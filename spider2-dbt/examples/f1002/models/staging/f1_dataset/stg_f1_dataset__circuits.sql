with circuits as (
  select name as circuit_name,
         lat as latitude,
         lng as longitude,
         alt as alitude,
         circuitId as circuit_id,
         country,
         url as circuit_url,
         circuitRef as circuit_ref,
         location as circuit_location

    from {{ ref('circuits') }}
)

select *
  from circuits