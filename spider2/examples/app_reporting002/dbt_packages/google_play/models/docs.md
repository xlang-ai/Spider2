{% docs total_device_installs %}
Cumulative number of device installs up to and including this day (aggregated on the dimension of this table). This does not take uninstalls into account and may contain duplicate devices.
{% enddocs %}

{% docs total_device_uninstalls %}
Cumulative number of device uninstalls up to and including this day (aggregated on the dimension of this table). This does not take re-installs into account and may contain duplicate devices.
{% enddocs %}

{% docs net_device_installs %}
Cumulative net number of device installs up to and including this day (aggregated on the dimension of this table). This is the difference of `total_device_installs` and `total_device_uninstalls`.
{% enddocs %}

{% docs total_store_visitors %}
Cumulative number of users that visited your store listing who did not have your app installed on any device at the time.
{% enddocs %}

{% docs total_store_acquisitions %}
Cumulative number of users that visited your store listing and installed your app, who did not have your app installed on any device prior to this.
{% enddocs %}

{% docs rolling_store_conversion_rate %}
Rolling percentage of store listing visitors who installed your app within a given country. The ratio of `total_store_acquisitions` to `total_store_visitors`.
{% enddocs %}
{% docs source_relation %}
The source of the record if the unioning functionality is being used. If not this field will be empty.
{% enddocs %}