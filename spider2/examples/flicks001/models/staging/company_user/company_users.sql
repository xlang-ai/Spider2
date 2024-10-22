with users as (
    select * from {{ source('netflix', 'company_user') }}
)
select *,
       regexp_matches(login_email, '^[A-Za-z0-9._%+-]+@example.com$') as valid_email
  from users
