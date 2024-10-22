
with source as (

    select * from {{ source('google_sheets', 'GOOGLE_SHEETS__ORIGINAL_CATEGORIES') }}

),

standardized as (

  -- project focus is only on three categories
  select
      case 
        when category = '1Drama' then 1
        when category = '2Comedy' then 2
        when category like '%6.1Docuseries%' then 3
        else null
      end as category_id
    , case
        when category = '1Drama' then 'Drama'
        when category = '2Comedy' then 'Comedy'
        when category like '%6.1Docuseries%' then 'Docuseries'
        else category
      end as category
    , updated_at as updated_at_utc
  from source

)

select * from standardized
-- where category_id in (1, 2, 3)    -- move to intermediate table