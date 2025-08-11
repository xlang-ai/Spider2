{% set employee_models = ['pa0000', 'pa0001', 'pa0007', 'pa0008', 'pa0031'] %}

with
{% for employee_model in employee_models %}
    {{ employee_model }}_beg as (
        select
            pernr,
            begda as date_change
        from {{ var(employee_model) }}
    ),

    {{ employee_model }}_end as (
        select
            pernr,
			{{ add_day_to_char_date('endda') }} as date_change
		from {{ var(employee_model) }}
	), 
{% endfor %}


unioned as (

	{% for employee_model in employee_models %}
		select 
			pernr,
			date_change 
		from {{ employee_model }}_beg 

		union all

		select 
			pernr,
			date_change 
		from {{ employee_model }}_end 

		{% if not loop.last %}
		union all
		{% endif %} 
	{% endfor %}
),
	

unioned_dates as (
	
	select pernr, date_change 
	from unioned
	{{ dbt_utils.group_by(2) }}
	order by pernr, date_change
),

employee_date_ranges as (

	select 
		pernr,
		date_change as begda,
		lead(date_change, 1) over (partition by pernr order by date_change) as endda      
	from unioned_dates			
),

employee_original_date_ranges as (
	select
		pernr,
		begda,
		strftime('%Y%m%d', date_add('-1 day', strptime(cast(endda as varchar), '%Y%m%d'))) as endda
	from employee_date_ranges
)


select * 
from employee_original_date_ranges