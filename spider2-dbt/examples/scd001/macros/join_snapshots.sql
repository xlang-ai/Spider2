-- requires any extra columns from table_join_on to be listed prior to using this macro.
-- assumes we have replaced instances of valid_to = null with a future_proof_date = '9999-12-31'.
-- source: https://docs.getdbt.com/blog/joining-snapshot-complexity?utm_content=210039579&utm_medium=social&utm_source=linkedin&hss_channel=lcp-10893210
 
{% macro join_snapshots(cte_join, cte_join_on, cte_join_valid_to,
   cte_join_valid_from, cte_join_on_valid_to, cte_join_on_valid_from,
   cte_join_id, cte_join_on_id) %}
 
 
       {{cte_join}}.*,
       greatest({{cte_join}}.{{cte_join_valid_from}},
               coalesce( {{cte_join_on}}.{{cte_join_on_valid_from}}, {{cte_join}}.{{cte_join_valid_from}}))
           as add_{{cte_join_on}}_valid_from,
       least({{cte_join}}.{{cte_join_valid_to}},
           coalesce({{cte_join_on}}.{{cte_join_on_valid_to}}, {{cte_join}}.{{cte_join_valid_to}})) as add_{{cte_join_on}}_valid_to
  
   from {{cte_join}}
   left join {{cte_join_on}} on {{cte_join}}.{{cte_join_id}} = {{cte_join_on}}.{{cte_join_on_id}}
       and (({{cte_join_on}}.{{cte_join_on_valid_from}} >= {{cte_join}}.{{cte_join_valid_from}}
       and {{cte_join_on}}.{{cte_join_on_valid_from}} < {{cte_join}}.{{cte_join_valid_to}})
       or ({{cte_join_on}}.{{cte_join_on_valid_to}} >= {{cte_join}}.{{cte_join_valid_from}}
       and {{cte_join_on}}.{{cte_join_on_valid_to}} < {{cte_join}}.{{cte_join_valid_to}})
       or ({{cte_join_on}}.{{cte_join_on_valid_from}} <= {{cte_join}}.{{cte_join_valid_from}}
       and {{cte_join_on}}.{{cte_join_on_valid_to}} > {{cte_join}}.{{cte_join_valid_from}}))
      
  
{% endmacro %}