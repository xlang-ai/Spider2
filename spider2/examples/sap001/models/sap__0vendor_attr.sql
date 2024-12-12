with lfa1 as ( 

	select * 
	from {{ var('lfa1') }}
),

final as (

    select
        mandt,
        lifnr,
        brsch,
        ktokk,
        land1,
        loevm,
        name1,
        name2,
        name3,
        ort01,
        ort02,
        pfach,
        pstl2,
        pstlz,
        regio,
        sortl,
        spras,
        stcd1,
        stcd2,
        stcd3,
        stras,
        telf1,
        telfx,
        xcpdk,
        vbund,
        kraus,
        pfort,
        werks
    from lfa1

    {% if var('lfa1_mandt_var',[]) %}
    where mandt = '{{ var('lfa1_mandt_var') }}'
    {% endif %}
)

select *
from final