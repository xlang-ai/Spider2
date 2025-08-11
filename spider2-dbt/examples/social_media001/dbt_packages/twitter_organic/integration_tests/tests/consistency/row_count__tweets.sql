{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select 
        organic_tweet_id,
        source_relation,
        count(*) as total_count
    from {{ target.schema }}_twitter_organic_prod.twitter_organic__tweets
    group by 1, 2
),

dev as (
    select 
        organic_tweet_id,
        source_relation,
        count(*) as total_count
    from {{ target.schema }}_twitter_organic_dev.twitter_organic__tweets
    group by 1, 2
),

final as (
    select
        prod.organic_tweet_id as prod_id,
        dev.organic_tweet_id as dev_id,
        prod.source_relation as prod_source_relation,
        dev.source_relation as dev_source_relation,
        prod.total_count as prod_count,
        dev.total_count as dev_count
    from prod
    full outer join dev
        on dev.organic_tweet_id = prod.organic_tweet_id
        and dev.source_relation = prod.source_relation
)

select *
from final
where prod_count != dev_count