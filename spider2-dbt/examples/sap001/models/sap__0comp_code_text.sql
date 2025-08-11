with t001 as ( 

	select * 
	from {{ var('t001') }}
),

final as (

    select
        mandt,
        bukrs,
        butxt as txtmd,
        spras as langu
    from t001
)

select * 
from final