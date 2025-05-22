with npi_source as (

    select
          npi
        , entity_type_code
        , "provider_last_name_(legal_name)" AS provider_last_name
        , provider_first_name
        , "provider_organization_name_(legal_business_name)" AS provider_organization_name
        , parent_organization_lbn
        , provider_first_line_business_practice_location_address
        , provider_second_line_business_practice_location_address
        , provider_business_practice_location_address_city_name
        , provider_business_practice_location_address_state_name
        , provider_business_practice_location_address_postal_code
        , strptime(last_update_date, '%m/%d/%Y') as last_update_date
        , strptime(npi_deactivation_date, '%m/%d/%Y') as npi_deactivation_date
    from {{ source('nppes', 'npi') }}

),

primary_taxonomy as (

    select
          npi
        , taxonomy_code
        , description
    from {{ ref('other_provider_taxonomy') }}
    where primary_flag = 1

)

select
      npi_source.npi
    , npi_source.entity_type_code
    , case
        when npi_source.entity_type_code = '1' then 'Individual'
        when npi_source.entity_type_code = '2' then 'Organization'
        end as entity_type_description
    , primary_taxonomy.taxonomy_code as primary_taxonomy_code
    , primary_taxonomy.description as primary_specialty_description
    , UPPER(SUBSTRING(npi_source.provider_first_name, 1, 1)) || LOWER(SUBSTRING(npi_source.provider_first_name, 2)) as provider_first_name
    , UPPER(SUBSTRING(npi_source.provider_last_name, 1, 1)) || LOWER(SUBSTRING(npi_source.provider_last_name, 2)) as provider_last_name
    , UPPER(SUBSTRING(npi_source.provider_organization_name, 1, 1)) || LOWER(SUBSTRING(npi_source.provider_organization_name, 2)) as provider_organization_name
    , UPPER(SUBSTRING(npi_source.parent_organization_lbn, 1, 1)) || LOWER(SUBSTRING(npi_source.parent_organization_lbn, 2)) as parent_organization_name
    , UPPER(SUBSTRING(npi_source.provider_first_line_business_practice_location_address, 1, 1)) || LOWER(SUBSTRING(npi_source.provider_first_line_business_practice_location_address, 2)) as practice_address_line_1
    , UPPER(SUBSTRING(npi_source.provider_second_line_business_practice_location_address, 1, 1)) || LOWER(SUBSTRING(npi_source.provider_second_line_business_practice_location_address, 2)) as practice_address_line_2
    , UPPER(SUBSTRING(npi_source.provider_business_practice_location_address_city_name, 1, 1)) || LOWER(SUBSTRING(npi_source.provider_business_practice_location_address_city_name, 2)) as practice_city
    , npi_source.provider_business_practice_location_address_state_name as practice_state
    , npi_source.provider_business_practice_location_address_postal_code as practice_zip_code
    , cast(last_update_date as date) as last_updated
    , cast(npi_deactivation_date as date) as deactivation_date
    , case
        when npi_deactivation_date is not null then 1
        else 0
      end as deactivation_flag
from npi_source
     left join primary_taxonomy
     on npi_source.npi = primary_taxonomy.npi
