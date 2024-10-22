with hour_spine as (
    {% for hour in range(24) -%}
        select {{ hour }} as hour
        {% if not loop.last %} union all {% endif %}
    {%- endfor -%}
),
minute_spine as (
    {% for minute in range(60) -%}
        select {{ minute }} as minute
        {% if not loop.last %} union all {% endif %}
    {%- endfor -%}
),
second_spine as (
    {% for second in range(60) -%}
        select {{ second }} as second
        {% if not loop.last %} union all {% endif %}
    {%- endfor -%}
),
hour_minute_spine as (
    select
        make_time(hour, minute, second) as moment,
        hour,
        minute,
        second,
        make_time(hour, 0, 0) as start_of_hour,
        make_time(hour, minute, 0) as start_of_minute,
        case when hour < 12 then 'AM' else 'PM' end as am_pm,
        case
            when hour < 6 then 'night'
            when hour < 12 then 'morning'
            when hour < 18 then 'afternoon'
            when hour < 23 then 'evening'
            else 'night'
        end as part_of_day
    from hour_spine
    cross join minute_spine
    cross join second_spine
),

final as (
    select
        *
    from hour_minute_spine
    order by moment asc
)

select * from final
