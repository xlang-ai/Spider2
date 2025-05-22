with issue_multiselect_history as (

    select *
    from {{ var('issue_multiselect_history') }}
    
), 

fields as (
      
    select *
    from {{ var('field') }}

), 

joined as (
  
  select
    issue_multiselect_history.*,
    lower(fields.field_name) as field_name

  from issue_multiselect_history
  join fields 
    on fields.field_id = issue_multiselect_history.field_id

)

select *
from joined