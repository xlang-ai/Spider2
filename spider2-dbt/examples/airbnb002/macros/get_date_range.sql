{% macro get_date_range(target_date='SYSDATE',lookback=7) %}

	{%- set date_range_query -%}

		{%- for i in range (0,lookback+1) -%}

		SELECT {{target_date}}::DATE - {{i}} AS dates
		{% if not loop.last -%} UNION ALL {%- endif -%}

		{%- endfor -%}

	{%- endset -%}

	{%- set date_range_results = run_query(date_range_query) -%}

	{%- if execute -%}
		{%- set date_range_results_list = results.columns[0].values() -%}
	{%- else -%}
		{%- set date_range_results_list = [] -%}
	{%- endif -%}

	
	{{return(date_range_results_list)}}


{% endmacro %}