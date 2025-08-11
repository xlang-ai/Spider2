{% macro first_value(first_value_field, partition_field, order_by_field, order="asc") -%}

{{ adapter.dispatch('first_value', 'fivetran_utils') (first_value_field, partition_field, order_by_field, order) }}

{%- endmacro %}

--Default first_value calculation
{% macro default__first_value(first_value_field, partition_field, order_by_field, order="asc")  %}

    first_value( {{ first_value_field }} ignore nulls ) over (partition by {{ partition_field }} order by {{ order_by_field }} {{ order }} )

{% endmacro %}

--first_value calculation specific to Redshift
{% macro redshift__first_value(first_value_field, partition_field, order_by_field, order="asc") %}

    first_value( {{ first_value_field }} ignore nulls ) over (partition by {{ partition_field }} order by {{ order_by_field }} {{ order }} , {{ partition_field }} rows unbounded preceding )

{% endmacro %}