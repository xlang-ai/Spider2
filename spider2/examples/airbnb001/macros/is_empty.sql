{% macro is_empty(schema,model) %}

	{%- set checking_query -%}
	SELECT COUNT(*) FROM {{schema}}.{{model}} LIMIT 5
	{%- endset -%}

	{%- set checking_query_result = run_query(checking_query) -%}

	{%- if execute-%}
		{%-set checking_query_result_list = checking_query_result.columns[0].values() -%}
	{%- else -%}
		{%- set checking_query_result_list = [] -%}
	{%- endif -%}

	{%- if checking_query_result_list[0] == 0 -%}
		{{return(true)}}
	{%- else -%}
		{{return(false)}}
	{%- endif -%}

{% endmacro %}