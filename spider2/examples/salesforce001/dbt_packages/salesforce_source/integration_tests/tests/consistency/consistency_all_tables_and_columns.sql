{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

/* This test is to make sure the final columns produced are the same between versions.
Only one test is needed since it will fetch all tables and all columns in each schema.
!!! THIS TEST IS WRITTEN FOR BIGQUERY!!! */
{% if target.type == 'bigquery' %}
with prod as (
    select
        table_name,
        column_name,
        data_type
    from {{ target.schema }}_salesforce_source_prod.INFORMATION_SCHEMA.COLUMNS
    where table_name like 'stg_%'
),

dev as (
    select
        table_name,
        column_name,
        data_type
    from {{ target.schema }}_salesforce_source_dev.INFORMATION_SCHEMA.COLUMNS
    where table_name like 'stg_%'
),

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final

{% else %}
{{ print('This is written to run on bigquery. If you need to run on another warehouse, add a version!') }}

{% endif %}