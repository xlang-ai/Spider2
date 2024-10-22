with accounts as (

    select *
    from {{ var('account_history_staging') }}

), is_most_recent as (

    select 
        *,
        {{ twitter_organic.result_if_table_exists(
            table_ref=var('account_history_staging'), 
            result_statement='row_number() over (partition by account_id' ~ (', source_relation' if var('twitter_organic_union_schemas', []) or var('twitter_organic_union_databases', []) | length > 1) ~ ' order by _fivetran_synced desc)',
            if_empty=1
        )}} = 1 as is_most_recent_record

    from accounts

)

select *
from is_most_recent