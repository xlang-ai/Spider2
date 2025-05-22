with kna1 as ( 

	select * 
	from {{ var('kna1') }}
),

final as (

    select
        mandt,
        kunnr,
        brsch,
        ktokd,
        kukla,
        land1,
        lifnr,
        loevm,
        name1,
        niels,
        ort01,
        pstlz,
        regio,
        counc,
        stcd1,
        stras,
        telf1,
        vbund,
        bran1,
        bran2,
        bran3,
        bran4,
        bran5,
        periv,
        abrvw,
        werks,
        name2,
        name3,
        dear6,
        pstl2
    from kna1

    {% if var('kna1_mandt_var',[]) %}
	where mandt = '{{ var('kna1_mandt_var') }}'
	{% endif %}
 
)

select * 
from final