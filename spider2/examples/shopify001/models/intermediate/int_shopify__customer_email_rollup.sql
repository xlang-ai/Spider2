with customers as (

    select 
        *,
        row_number() over(
            partition by {{ shopify.shopify_partition_by_cols('email', 'source_relation') }}
            order by created_timestamp desc) 
            as customer_index

    from {{ var('shopify_customer') }}
    where email is not null -- nonsensical to include any null emails here

), customer_tags as (

    select 
        *
    from {{ var('shopify_customer_tag' )}}

), rollup_customers as (

    select
        -- fields to group by
        lower(customers.email) as email,
        customers.source_relation,

        -- fields to string agg together
        {{ fivetran_utils.string_agg("distinct cast(customers.customer_id as " ~ dbt.type_string() ~ ")", "', '") }} as customer_ids,
        {{ fivetran_utils.string_agg("distinct cast(customers.phone as " ~ dbt.type_string() ~ ")", "', '") }} as phone_numbers,
        {{ fivetran_utils.string_agg("distinct cast(customer_tags.value as " ~ dbt.type_string() ~ ")", "', '") }} as customer_tags,

        -- fields to take aggregates of
        min(customers.created_timestamp) as first_account_created_at,
        max(customers.created_timestamp) as last_account_created_at,
        max(customers.updated_timestamp) as last_updated_at,
        max(customers.marketing_consent_updated_at) as marketing_consent_updated_at,
        max(customers._fivetran_synced) as last_fivetran_synced,

        -- take true if ever given for boolean fields
        {{ fivetran_utils.max_bool("case when customers.customer_index = 1 then customers.is_tax_exempt else null end") }} as is_tax_exempt, -- since this changes every year
        {{ fivetran_utils.max_bool("customers.is_verified_email") }} as is_verified_email

        -- for all other fields, just take the latest value
        {% set cols = adapter.get_columns_in_relation(ref('stg_shopify__customer')) %}
        {% set except_cols = ['_fivetran_synced', 'email', 'source_relation', 'customer_id', 'phone', 'created_at', 
                                'marketing_consent_updated_at', 'orders_count', 'total_spent', 'created_timestamp', 'updated_timestamp',
                                'is_tax_exempt', 'is_verified_email'] %}
        {% for col in cols %}
            {% if col.column|lower not in except_cols %}
            , max(case when customers.customer_index = 1 then customers.{{ col.column }} else null end) as {{ col.column }}
            {% endif %}
        {% endfor %}

    from customers 
    left join customer_tags
        on customers.customer_id = customer_tags.customer_id
        and customers.source_relation = customer_tags.source_relation

    group by 1,2

)

select *
from rollup_customers
