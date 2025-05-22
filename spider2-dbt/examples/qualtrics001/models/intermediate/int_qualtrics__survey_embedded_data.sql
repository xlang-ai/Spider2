with survey_embedded_data as (

    select *
    from {{ var('survey_embedded_data') }}
),

jsonify as (

    select
        response_id, -- survey_response
        source_relation,
        '{' || {{ fivetran_utils.string_agg('key || ' ~ "':'" ~ ' || value', "', '") }} || '}' as embedded_data
    from survey_embedded_data
    group by 1,2
)

select 
    response_id,
    source_relation,
    embedded_data
from jsonify 
group by 1,2,3