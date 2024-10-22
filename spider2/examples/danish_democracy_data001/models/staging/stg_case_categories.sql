with

source as (

    select * from {{ source('danish_parliament', 'raw_sagskategori') }}
    qualify row_number() over (partition by id order by opdateringsdato desc) = 1

),

renamed as (
    select
        id as case_category_id,
        kategori as case_category,
        opdateringsdato as case_category_updated_at,
        filename as file_name
    from source
)

select * from renamed
