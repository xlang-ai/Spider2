
with source as (

    select * from {{ source('google_sheets', 'GOOGLE_SHEETS__ORIGINAL_DRAMAS') }}

),

standardized as (

    -- saving data standardization/cleaning for after union (to stay DRY)
    select 
        title
      , 1 as category_id
      , genre
      , premiere
      , seasons
      , runtime
      , status
      , updated_at -- switched to airbyte created column instead of google sheet created column
    from source

)

select * from standardized