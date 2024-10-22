with persons as (

    select
        *,
        row_number() over (partition by email order by created_at desc) as person_index
    
    from {{ ref('klaviyo__persons') }}
    where email is not null -- should never be the case but just in case

), aggregate_persons as (

    select 
        lower(email) as email,
        source_relation,
        {{ fivetran_utils.string_agg("person_id", "', '") }} as person_ids,
        {{ fivetran_utils.string_agg("distinct cast(phone_number as " ~ dbt.type_string() ~ ")", "', '") }} as phone_numbers,
        max( case when person_index = 1 then full_name else null end) as full_name,
        
        min(created_at) as first_klaviyo_account_made_at,
        max(created_at) as last_klaviyo_account_made_at,
        max(updated_at) as last_updated_at,
        min(first_event_at) as first_event_at,
        max(last_event_at) as last_event_at,
        min(first_campaign_touch_at) as first_campaign_touch_at,
        max(last_campaign_touch_at) as last_campaign_touch_at,
        min(first_flow_touch_at) as first_flow_touch_at,
        max(last_flow_touch_at) as last_flow_touch_at,

        sum(count_total_campaigns) as count_total_campaigns,
        sum(count_total_flows) as count_total_flows


        {% set cols = adapter.get_columns_in_relation(ref('klaviyo__persons')) %}
        {% set except_cols = ['_fivetran_synced', 'email', 'source_relation', 'person_id', 'phone_number', 'full_name', 'created_at', 'updated_at', 'count_total_campaigns', 'count_total_flows',
                                'first_event_at', 'last_event_at', 'first_campaign_touch_at', 'last_campaign_touch_at', 'first_flow_touch_at', 'last_flow_touch_at'] %}
        {% for col in cols %}
            {% if col.column|lower not in except_cols %}
            , max(case when person_index = 1 then {{ col.column }} else null end) as {{ col.column }}
            {% endif %}
        {% endfor %}

    from persons
    group by 1,2
)

select *
from aggregate_persons