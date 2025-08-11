with t001 as ( 

	select * 
	from {{ var('t001') }}
),

final as (

    select
        mandt,
        bukrs,
        land1,
        waers,
        ktopl,
        kkber,
        periv,
        rcomp
    from t001

    {% if var('t001_mandt_var',[]) %}
    where mandt = '{{ var('t001_mandt_var') }}'
    {% endif %}
)

select * 
from final