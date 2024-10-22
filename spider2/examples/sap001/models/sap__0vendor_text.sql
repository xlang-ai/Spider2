with lfa1 as ( 

	select * 
	from {{ var('lfa1') }}
),

final as (

    select
        mandt,
        lifnr,
        name1 as txtmd
    from lfa1
)

select * 
from final