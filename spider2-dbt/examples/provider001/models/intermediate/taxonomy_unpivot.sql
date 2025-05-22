with npi_source as (

    select
          npi
        , healthcare_provider_taxonomy_code_1
        , healthcare_provider_primary_taxonomy_switch_1
        , healthcare_provider_taxonomy_code_2
        , healthcare_provider_primary_taxonomy_switch_2
        , healthcare_provider_taxonomy_code_3
        , healthcare_provider_primary_taxonomy_switch_3
        , healthcare_provider_taxonomy_code_4
        , healthcare_provider_primary_taxonomy_switch_4
        , healthcare_provider_taxonomy_code_5
        , healthcare_provider_primary_taxonomy_switch_5
        , healthcare_provider_taxonomy_code_6
        , healthcare_provider_primary_taxonomy_switch_6
        , healthcare_provider_taxonomy_code_7
        , healthcare_provider_primary_taxonomy_switch_7
        , healthcare_provider_taxonomy_code_8
        , healthcare_provider_primary_taxonomy_switch_8
        , healthcare_provider_taxonomy_code_9
        , healthcare_provider_primary_taxonomy_switch_9
        , healthcare_provider_taxonomy_code_10
        , healthcare_provider_primary_taxonomy_switch_10
        , healthcare_provider_taxonomy_code_11
        , healthcare_provider_primary_taxonomy_switch_11
        , healthcare_provider_taxonomy_code_12
        , healthcare_provider_primary_taxonomy_switch_12
        , healthcare_provider_taxonomy_code_13
        , healthcare_provider_primary_taxonomy_switch_13
        , healthcare_provider_taxonomy_code_14
        , healthcare_provider_primary_taxonomy_switch_14
        , healthcare_provider_taxonomy_code_15
        , healthcare_provider_primary_taxonomy_switch_15
    from {{ source('nppes', 'npi') }}

),

unpivoted as (
    select npi, healthcare_provider_taxonomy_code_1 as taxonomy_code, healthcare_provider_primary_taxonomy_switch_1 as taxonomy_switch, '1' as taxonomy_col
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_2, healthcare_provider_primary_taxonomy_switch_2, '2'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_3, healthcare_provider_primary_taxonomy_switch_3, '3'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_4, healthcare_provider_primary_taxonomy_switch_4, '4'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_5, healthcare_provider_primary_taxonomy_switch_5, '5'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_6, healthcare_provider_primary_taxonomy_switch_6, '6'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_7, healthcare_provider_primary_taxonomy_switch_7, '7'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_8, healthcare_provider_primary_taxonomy_switch_8, '8'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_9, healthcare_provider_primary_taxonomy_switch_9, '9'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_10, healthcare_provider_primary_taxonomy_switch_10, '10'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_11, healthcare_provider_primary_taxonomy_switch_11, '11'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_12, healthcare_provider_primary_taxonomy_switch_12, '12'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_13, healthcare_provider_primary_taxonomy_switch_13, '13'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_14, healthcare_provider_primary_taxonomy_switch_14, '14'
    from npi_source
    union all
    select npi, healthcare_provider_taxonomy_code_15, healthcare_provider_primary_taxonomy_switch_15, '15'
    from npi_source
)

select *
from unpivoted
where taxonomy_col = taxonomy_switch
