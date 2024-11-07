with base as (

    select *
    from {{ ref('stg_google_play__stats_installs_app_version_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_google_play__stats_installs_app_version_tmp')),
                staging_columns=get_stats_installs_app_version_columns()
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
        cast(app_version_code as {{ dbt.type_int() }}) as app_version_code,
        cast(package_name as {{ dbt.type_string() }}) as package_name,
        sum(cast(active_device_installs as {{ dbt.type_bigint() }})) as active_devices_last_30_days,
        sum(cast(daily_device_installs as {{ dbt.type_bigint() }})) as device_installs,
        sum(cast(daily_device_uninstalls as {{ dbt.type_bigint() }})) as device_uninstalls,
        sum(cast(daily_device_upgrades as {{ dbt.type_bigint() }})) as device_upgrades,
        sum(cast(daily_user_installs as {{ dbt.type_bigint() }})) as user_installs,
        sum(cast(daily_user_uninstalls as {{ dbt.type_bigint() }})) as user_uninstalls,
        sum(cast(install_events as {{ dbt.type_bigint() }})) as install_events,
        sum(cast(uninstall_events as {{ dbt.type_bigint() }})) as uninstall_events,
        sum(cast(update_events as {{ dbt.type_bigint() }})) as update_events
    from fields
    {{ dbt_utils.group_by(4) }}
)

select *
from final
