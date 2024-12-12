
select * from {{ source('netflix', 'TITLES') }} where type = 'SHOW'