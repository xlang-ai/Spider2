{% macro percentile(percentile_field, partition_field, percent) -%}

{{ adapter.dispatch('percentile', 'fivetran_utils') (percentile_field, partition_field, percent) }}

{%- endmacro %}

--percentile calculation specific to Redshift
{% macro default__percentile(percentile_field, partition_field, percent)  %}

    percentile_cont( 
        {{ percent }} )
        within group ( order by {{ percentile_field }} )
        over ( partition by {{ partition_field }} )

{% endmacro %}

--percentile calculation specific to Redshift
{% macro redshift__percentile(percentile_field, partition_field, percent)  %}

    percentile_cont( 
        {{ percent }} )
        within group ( order by {{ percentile_field }} )
        over ( partition by {{ partition_field }} )

{% endmacro %}

--percentile calculation specific to BigQuery
{% macro bigquery__percentile(percentile_field, partition_field, percent)  %}

    percentile_cont( 
        {{ percentile_field }}, 
        {{ percent }}) 
        over (partition by {{ partition_field }}    
        )

{% endmacro %}

{% macro postgres__percentile(percentile_field, partition_field, percent)  %}

    percentile_cont( 
        {{ percent }} )
        within group ( order by {{ percentile_field }} )
    /* have to group by partition field */

{% endmacro %}

{% macro spark__percentile(percentile_field, partition_field, percent)  %}

    percentile( 
        {{ percentile_field }}, 
        {{ percent }}) 
        over (partition by {{ partition_field }}    
        )

{% endmacro %}