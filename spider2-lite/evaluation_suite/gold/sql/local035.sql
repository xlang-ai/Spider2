select city_one, city_two from (
  Select
    a.geolocation_city as city_one,
    lag(a.geolocation_city) over(order by a.geolocation_state,a.geolocation_city,a.geolocation_zip_code_prefix,a.geolocation_lat,a.geolocation_lng asc) as city_two,
    a.distance_between_two_cities - lag(a.distance_between_two_cities) over(order by a.geolocation_state,a.geolocation_city,a.geolocation_zip_code_prefix,a.geolocation_lat,a.geolocation_lng asc) as Distance
  from (
    SELECT *,(6371 * acos(
      cos( radians(geolocation_lat) )
      * cos( radians(lag(geolocation_lat) over(order by geolocation_state,geolocation_city,geolocation_zip_code_prefix,geolocation_lat,geolocation_lng asc) ) )
      * cos( radians(lag(geolocation_lng) over(order by geolocation_state,geolocation_city,geolocation_zip_code_prefix,geolocation_lat,geolocation_lng asc) ) - radians(geolocation_lng) )
      + sin( radians(lag(geolocation_lng) over(order by geolocation_state,geolocation_city,geolocation_zip_code_prefix,geolocation_lat,geolocation_lng asc)) )
      * sin( radians(lag(geolocation_lat) over(order by geolocation_state,geolocation_city,geolocation_zip_code_prefix,geolocation_lat,geolocation_lng asc) ) )
    ) ) as distance_between_two_cities from olist_geolocation
  ) a
  group by 1
) result
group by 1,2
order by result.Distance desc
LIMIT 1
