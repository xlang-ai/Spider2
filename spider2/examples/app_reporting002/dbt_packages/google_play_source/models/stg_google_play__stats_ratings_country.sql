with base as (

    select *
    from {{ ref('stg_google_play__stats_ratings_country_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_google_play__stats_ratings_country_tmp')),
                staging_columns=get_stats_ratings_country_columns()
            )
        }}

    
        {{ fivetran_utils.source_relation(
            union_schema_variable='google_play_union_schemas', 
            union_database_variable='google_play_union_databases') 
        }}

    from base
),

final as (

    select
        cast(source_relation as {{ dbt.type_string() }}) as source_relation,
        cast(date as date) as date_day,
        cast(country as {{ dbt.type_string() }}) as country,
        cast(package_name as {{ dbt.type_string() }}) as package_name,
        case when country is null then null else cast( nullif(cast(daily_average_rating as {{ dbt.type_string() }}), 'NA') as {{ dbt.type_float() }} ) end as average_rating,
        case when country is null then null else total_average_rating end as rolling_total_average_rating
    from fields
    {{ dbt_utils.group_by(6) }}
)

select *
from final
