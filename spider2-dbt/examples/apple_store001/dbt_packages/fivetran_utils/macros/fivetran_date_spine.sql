{% macro fivetran_date_spine(datepart, start_date, end_date) -%}

{{ return(adapter.dispatch('fivetran_date_spine', 'fivetran_utils') (datepart, start_date, end_date)) }}

{%- endmacro %}

{% macro default__fivetran_date_spine(datepart, start_date, end_date) %}

    {{ dbt_utils.date_spine(datepart, start_date, end_date) }}
        
{% endmacro %}

{% macro sqlserver__fivetran_date_spine(datepart, start_date, end_date) -%}

    {% set date_spine_query %}
        with

        l0 as (

            select c
            from (select 1 union all select 1) as d(c)

        ),
        l1 as (

            select
                1 as c
            from l0 as a
            cross join l0 as b

        ),

        l2 as (

            select 1 as c
            from l1 as a
            cross join l1 as b
        ),

        l3 as (

            select 1 as c
            from l2 as a
            cross join l2 as b
        ),

        l4 as (

            select 1 as c
            from l3 as a
            cross join l3 as b
        ),

        l5 as (

            select 1 as c
            from l4 as a
            cross join l4 as b
        ),

        nums as (

            select row_number() over (order by (select null)) as rownum
            from l5
        ),

        rawdata as (

            select top ({{dbt.datediff(start_date, end_date, datepart)}}) rownum -1 as n
            from nums
            order by rownum
        ),

        all_periods as (

            select (
                {{
                    dbt.dateadd(
                        datepart,
                        'n',
                        start_date
                    )
                }}
            ) as date_{{datepart}}
            from rawdata
        ),

        filtered as (

            select *
            from all_periods
            where date_{{datepart}} <= {{ end_date }}

        )

        select * from filtered
        order by 1

    {% endset %}

    {% set results = run_query(date_spine_query) %}

    {% if execute %}

        {% set results_list = results.columns[0].values() %}
    
    {% else %}

        {% set results_list = [] %}

    {% endif %}

    {%- for date_field in results_list %}
        select cast('{{ date_field }}' as date) as date_{{datepart}} {{ 'union all ' if not loop.last else '' }}
    {% endfor -%}

{% endmacro %}