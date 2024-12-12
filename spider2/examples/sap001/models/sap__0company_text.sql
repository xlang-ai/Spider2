with t880 as ( 

	select * 
	from {{ var('t880') }}
),

final as (

    select 
        mandt,
        rcomp,
        name1 as txtmd
    from t880
)

select * 
from final