
select * from {{ source('netflix', 'TITLES') }} where type = 'MOVIE'