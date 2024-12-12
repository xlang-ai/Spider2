{% macro add_property_labels(passthrough_var_name, cte_name) %}

select {{ cte_name }}.*

{% if var(passthrough_var_name, []) != [] and var('hubspot_property_enabled', True) %}
  {% set source_name = passthrough_var_name.replace('hubspot__', '').replace('_pass_through_columns', '') %}
  {%- set col_list = var(passthrough_var_name) -%}

  {%- for col in col_list -%} -- Create label cols
    {%- if col.add_property_label or var('hubspot__enable_all_property_labels', false) -%}
      {%- set col_alias = (col.alias | default(col.name)) %}
      , {{ col.name }}_option.property_option_label as {{ col_alias }}_label
    {% endif -%}
  {%- endfor %}

  from {{ cte_name }}

  {% for col in col_list -%} -- Create joins
    {%- if col.add_property_label or var('hubspot__enable_all_property_labels', false) -%}
      {%- set col_alias = (col.alias | default(col.name)) %}

  left join -- create subset of property and property_options for property in question
    (select 
      property_option.property_option_value, 
      property_option.property_option_label
    from {{ ref('stg_hubspot__property_option') }} as property_option
    join {{ ref('stg_hubspot__property') }} as property
      on property_option.property_id = property._fivetran_id
    where property.property_name = '{{ col.name.replace('property_', '') }}'
      and property.hubspot_object = '{{ source_name }}'
    ) as {{ col.name }}_option

    on cast({{ cte_name }}.{{ col_alias }} as {{ dbt.type_string() }})
      = cast({{ col.name }}_option.property_option_value as {{ dbt.type_string() }})

    {% endif -%}
  {%- endfor %}

{%- else -%}
  from {{ cte_name }}

{%- endif -%}
{% endmacro %}