SELECT user
FROM (
Select user
      From `bigquery-public-data.eclipse_megamovie.photos_v_0_1`
      UNION ALL
      Select user
      From`bigquery-public-data.eclipse_megamovie.photos_v_0_2`
      UNION ALL
      Select user
      From`bigquery-public-data.eclipse_megamovie.photos_v_0_3`
) 
GROUP BY user 
HAVING COUNT (user)=( 
SELECT MAX(mycount) 
FROM ( 
SELECT user, COUNT(user) mycount 
FROM (
Select user
      From `bigquery-public-data.eclipse_megamovie.photos_v_0_1`
      UNION ALL
      Select user
      From`bigquery-public-data.eclipse_megamovie.photos_v_0_2`
      UNION ALL
      Select user
      From`bigquery-public-data.eclipse_megamovie.photos_v_0_3`
)
GROUP BY user))
ORDER BY COUNT(user) 
LIMIT 1