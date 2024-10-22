with constructors as (
  select constructorId as constructor_id,
         constructorRef as constructor_ref,
         name as constructor_name,
         nationality as constructor_nationality,
         url as constructor_url
    from {{ ref('constructors') }}
)

select *
  from constructors