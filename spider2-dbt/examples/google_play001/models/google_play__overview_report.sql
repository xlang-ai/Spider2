with installs as (

    select *
    from {{ var('stats_installs_overview') }}
), 

ratings as (

    select *
    from {{ var('stats_ratings_overview') }}
), 

crashes as (

    select *
    from {{ var('stats_crashes_overview') }}
), 

store_performance as (

    select *
    from {{ ref('int_google_play__store_performance') }} -- country rollup
), 

install_metrics as (

    select
        *,
        sum(device_installs) over (partition by source_relation, package_name order by date_day asc rows between unbounded preceding and current row) as total_device_installs,
        sum(device_uninstalls) over (partition by source_relation, package_name order by date_day asc rows between unbounded preceding and current row) as total_device_uninstalls
    from installs 
), 

overview_join as (

    select 
        -- these 3 columns are the grain of this model
        coalesce(install_metrics.source_relation, ratings.source_relation, store_performance.source_relation, crashes.source_relation) as source_relation,
        coalesce(install_metrics.date_day, ratings.date_day, store_performance.date_day, crashes.date_day) as date_day,
        coalesce(install_metrics.package_name, ratings.package_name, store_performance.package_name, crashes.package_name) as package_name,

        -- metrics based on unique devices + users
        coalesce(install_metrics.active_devices_last_30_days, 0) as active_devices_last_30_days,
        coalesce(install_metrics.device_installs, 0) as device_installs,
        coalesce(install_metrics.device_uninstalls, 0) as device_uninstalls,
        coalesce(install_metrics.device_upgrades, 0) as device_upgrades,
        coalesce(install_metrics.user_installs, 0) as user_installs,
        coalesce(install_metrics.user_uninstalls, 0) as user_uninstalls,
        coalesce(store_performance.store_listing_acquisitions, 0) as store_listing_acquisitions,
        coalesce(store_performance.store_listing_visitors, 0) as store_listing_visitors,
        store_performance.store_listing_conversion_rate, -- not coalescing if there aren't any visitors 

        -- metrics based on events. a user or device can have multiple installs in one day
        coalesce(crashes.crashes, 0) as crashes,
        coalesce(crashes.anrs, 0) as anrs,
        coalesce(install_metrics.install_events, 0) as install_events,
        coalesce(install_metrics.uninstall_events, 0) as uninstall_events,
        coalesce(install_metrics.update_events, 0) as update_events,    

        -- all of the following fields (except average_rating) are rolling metrics that we'll use window functions to backfill instead of coalescing
        install_metrics.total_device_installs,
        install_metrics.total_device_uninstalls,
        ratings.average_rating, -- this one actually isn't rolling but we won't coalesce days with no reviews to 0 rating. todo: move
        ratings.rolling_total_average_rating,
        store_performance.total_store_acquisitions,
        store_performance.total_store_visitors
    from install_metrics
    full outer join ratings
        on install_metrics.date_day = ratings.date_day
        and install_metrics.source_relation = ratings.source_relation
        and install_metrics.package_name = ratings.package_name
    full outer join store_performance
        on store_performance.date_day = coalesce(install_metrics.date_day, ratings.date_day)
        and store_performance.source_relation = coalesce(install_metrics.source_relation, ratings.source_relation)
        and store_performance.package_name = coalesce(install_metrics.package_name, ratings.package_name)
    full outer join crashes
        on coalesce(install_metrics.date_day, ratings.date_day, store_performance.date_day) = crashes.date_day
        and coalesce(install_metrics.source_relation, ratings.source_relation, store_performance.source_relation) = crashes.source_relation
        and coalesce(install_metrics.package_name, ratings.package_name, store_performance.package_name) = crashes.package_name
),

-- to backfill in days with NULL values for rolling metrics, we'll create partitions to batch them together with records that have non-null values
-- we can't just use last_value(ignore nulls) because of postgres :/
create_partitions as (

    select
        *

    {%- set rolling_metrics = ['rolling_total_average_rating', 'total_device_installs', 'total_device_uninstalls', 'total_store_acquisitions', 'total_store_visitors'] -%}

    {% for metric in rolling_metrics -%}
        , sum(case when {{ metric }} is null 
                then 0 else 1 end) over (partition by source_relation, package_name order by date_day asc rows unbounded preceding) as {{ metric | lower }}_partition
    {%- endfor %}
    from overview_join
), 

-- now we'll take the non-null value for each partitioned batch and propagate it across the rows included in the batch
fill_values as (

    select 
        source_relation,
        date_day,
        package_name,
        active_devices_last_30_days,
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
        store_listing_acquisitions,
        store_listing_visitors,
        store_listing_conversion_rate,
        average_rating

        {% for metric in rolling_metrics -%}

        , first_value( {{ metric }} ) over (
            partition by source_relation, {{ metric | lower }}_partition, package_name order by date_day asc rows between unbounded preceding and current row) as {{ metric }}

        {%- endfor %}
    from create_partitions
), 

final as (

    select 
        source_relation,
        date_day,
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
        store_listing_acquisitions,
        store_listing_visitors,
        store_listing_conversion_rate,
        active_devices_last_30_days,
        average_rating,

        -- leave null if there are no ratings yet
        rolling_total_average_rating, 

        -- the first day will have NULL values, let's make it 0
        coalesce(total_device_installs, 0) as total_device_installs,
        coalesce(total_device_uninstalls, 0) as total_device_uninstalls,
        coalesce(total_store_acquisitions, 0) as total_store_acquisitions,
        coalesce(total_store_visitors, 0) as total_store_visitors,

        -- calculate percentage and difference rolling metrics
        round( cast(total_store_acquisitions as {{ dbt.type_numeric() }}) / nullif(total_store_visitors, 0), 4) as rolling_store_conversion_rate,
        coalesce(total_device_installs, 0) - coalesce(total_device_uninstalls, 0) as net_device_installs
    from fill_values
)

select *
from final