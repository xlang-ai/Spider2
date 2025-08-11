with installs as (

    select *
    from {{ var('stats_installs_os_version') }}
), 

ratings as (

    select *
    from {{ var('stats_ratings_os_version') }}
), 

crashes as (

    select *
    from {{ var('stats_crashes_os_version') }}
), 

install_metrics as (

    select
        *,
        sum(device_installs) over (partition by source_relation, android_os_version, package_name order by date_day asc rows between unbounded preceding and current row) as total_device_installs,
        sum(device_uninstalls) over (partition by source_relation, android_os_version, package_name order by date_day asc rows between unbounded preceding and current row) as total_device_uninstalls
    from installs 
), 

app_version_join as (

    select 
        -- these 4 columns are the grain of this model
        coalesce(install_metrics.source_relation, ratings.source_relation, crashes.source_relation) as source_relation,
        coalesce(install_metrics.date_day, ratings.date_day, crashes.date_day) as date_day,
        coalesce(install_metrics.android_os_version, ratings.android_os_version, crashes.android_os_version) as android_os_version,
        coalesce(install_metrics.package_name, ratings.package_name, crashes.package_name) as package_name,

        -- metrics based on unique devices + users
        coalesce(install_metrics.active_devices_last_30_days, 0) as active_devices_last_30_days,
        coalesce(install_metrics.device_installs, 0) as device_installs,
        coalesce(install_metrics.device_uninstalls, 0) as device_uninstalls,
        coalesce(install_metrics.device_upgrades, 0) as device_upgrades,
        coalesce(install_metrics.user_installs, 0) as user_installs,
        coalesce(install_metrics.user_uninstalls, 0) as user_uninstalls,
        
        -- metrics based on events. a user or device can have multiple events in one day
        coalesce(crashes.crashes, 0) as crashes,
        coalesce(crashes.anrs, 0) as anrs,
        coalesce(install_metrics.install_events, 0) as install_events,
        coalesce(install_metrics.uninstall_events, 0) as uninstall_events,
        coalesce(install_metrics.update_events, 0) as update_events,    

        -- all of the following fields (except average_rating) are rolling metrics that we'll use window functions to backfill instead of coalescing
        install_metrics.total_device_installs,
        install_metrics.total_device_uninstalls,
        ratings.average_rating, -- this one actually isn't rolling but we won't coalesce days with no reviews to 0 rating
        ratings.rolling_total_average_rating
    from install_metrics
    full outer join ratings
        on install_metrics.date_day = ratings.date_day
        and install_metrics.source_relation = ratings.source_relation
        and install_metrics.package_name = ratings.package_name
        -- coalesce null os versions otherwise they'll cause fanout with the full outer join
        and coalesce(install_metrics.android_os_version, 'null_os_version') = coalesce(ratings.android_os_version, 'null_os_version') -- in the source package we aggregate all null device-type records together into one batch per day
    full outer join crashes
        on coalesce(install_metrics.date_day, ratings.date_day) = crashes.date_day
        and coalesce(install_metrics.source_relation, ratings.source_relation) = crashes.source_relation
        and coalesce(install_metrics.package_name, ratings.package_name) = crashes.package_name
        -- coalesce null countries otherwise they'll cause fanout with the full outer join
        and coalesce(install_metrics.android_os_version, ratings.android_os_version, 'null_os_version') = coalesce(crashes.android_os_version, 'null_os_version') -- in the source package we aggregate all null device-type records together into one batch per day
), 

-- to backfill in days with NULL values for rolling metrics, we'll create partitions to batch them together with records that have non-null values
-- we can't just use last_value(ignore nulls) because of postgres :/
create_partitions as (

    select
        *

    {%- set rolling_metrics = ['rolling_total_average_rating', 'total_device_installs', 'total_device_uninstalls'] -%}

    {% for metric in rolling_metrics -%}
        , sum(case when {{ metric }} is null 
                then 0 else 1 end) over (partition by source_relation, android_os_version, package_name order by date_day asc rows unbounded preceding) as {{ metric | lower }}_partition
    {%- endfor %}
    from app_version_join
), 

-- now we'll take the non-null value for each partitioned batch and propagate it across the rows included in the batch
fill_values as (

    select 
        source_relation,
        date_day,
        android_os_version,
        package_name,
        device_installs,
        device_uninstalls,
        device_upgrades,
        user_installs,
        user_uninstalls,
        crashes,
        anrs,
        install_events,
        uninstall_events,
        update_events,
        active_devices_last_30_days,
        average_rating

        {% for metric in rolling_metrics -%}

        , first_value( {{ metric }} ) over (
            partition by source_relation, {{ metric | lower }}_partition, android_os_version, package_name order by date_day asc rows between unbounded preceding and current row) as {{ metric }}

        {%- endfor %}
    from create_partitions
), 

final as (

    select 
        source_relation,
        date_day,
        android_os_version,
        package_name,
        device_installs,
        device_uninstalls,
        device_upgrades,
        user_installs,
        user_uninstalls,
        crashes,
        anrs,
        install_events,
        uninstall_events,
        update_events,
        active_devices_last_30_days,
        average_rating,

        -- leave null if there are no ratings yet
        rolling_total_average_rating,

        -- the first day will have NULL values, let's make it 0
        coalesce(total_device_installs, 0) as total_device_installs,
        coalesce(total_device_uninstalls, 0) as total_device_uninstalls,

        -- calculate difference rolling metric
        coalesce(total_device_installs, 0) - coalesce(total_device_uninstalls, 0) as net_device_installs
    from fill_values
)

select *
from final