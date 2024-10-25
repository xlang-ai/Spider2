{% macro get_missing_dates(schema,model,column,target_date='CURRENT_DATE',lookback=7) %}

	{% set missing_dates_query %}
	SELECT A.date_actual
	FROM dev.dim_dates A
	LEFT JOIN {{schema}}.{{model}} B
		ON A.date_actual = B.{{column}}
	WHERE B.{{column}} IS NULL
		AND A.date_actual BETWEEN {{target_date}}::DATE - {{lookback}} AND {{target_date}}
	{% endset %}

	{%- set missing_dates_results = run_query(missing_dates_query) -%}

	{%- if execute -%}
		{%- set missing_dates_list = missing_dates_results.columns[0].values() -%}
	{%- else -%}
		{%- set missing_dates_list = [] -%}
	{%- endif -%}

	{{return(missing_dates_list)}}

{% endmacro %}