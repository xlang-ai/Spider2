{% docs _fivetran_synced %}
Timestamp of when Fivetran synced a record.
{% enddocs %}

{% docs _file %}
The title of the monthly report csv from google.
{% enddocs %}

{% docs _line %}
Line of the monthly csv report that this record was read from.
{% enddocs %}

{% docs _modified %}
Timestamp of when the line was read from the monthly earnings report csv.
{% enddocs %}

{% docs date %}
The date on which the data is reported.
{% enddocs %}

{% docs package_name %}
The package name of the app owning the report data.
{% enddocs %}

{% docs daily_anrs %}
Daily application not responding (ANR) reports collected from Android devices whose users have opted in to automatically share usage and diagnostics data.
{% enddocs %}

{% docs daily_crashes %}
Daily crash reports collected from Android devices whose users have opted in to automatically share usage and diagnostics data.
{% enddocs %}

{% docs active_device_installs %}
The number of active devices on which your app is installed. An active device is one that has been turned on at least once in the past 30 days.
{% enddocs %}

{% docs current_device_installs %}
Seemingly deprecated column.
{% enddocs %}

{% docs current_user_installs %}
Seemingly deprecated column.
{% enddocs %}

{% docs daily_device_installs %}
Devices on which users installed your app on this day. An individual user can have multiple device installs.
{% enddocs %}

{% docs daily_device_uninstalls %}
The number of devices from which users uninstalled your app on a given day.
{% enddocs %}

{% docs daily_device_upgrades %}
The number of devices from which users upgraded your app on a given day.
{% enddocs %}

{% docs daily_user_installs %}
The number of users who installed your app and did not have it installed on any other devices at the time on a given day.
{% enddocs %}

{% docs daily_user_uninstalls %}
The number of users who uninstalled your app from all of their devices on this day.
{% enddocs %}

{% docs install_events %}
The number of times your app was installed, including devices on which the app had been installed previously. This does not include pre-installs or device reactivations.
{% enddocs %}

{% docs uninstall_events %}
The number of times your app was uninstalled. This does not include inactive devices.
{% enddocs %}

{% docs update_events %}
The number of times your app was updated.
{% enddocs %}

{% docs total_user_installs %}
Seemingly deprecated.
{% enddocs %}

{% docs daily_average_rating %}
Average star rating this app has received across all ratings submitted on a given day.
{% enddocs %}

{% docs total_average_rating %}
Average star rating this app received across all ratings submitted up to and including the past day. For each user submitting a rating, only their most recent rating of the app is counted.
{% enddocs %}

{% docs store_listing_acquisitions %}
The number of users that visited your store listing and installed your app, who did not have your app installed on any device.
{% enddocs %}

{% docs store_listing_visitors %}
The number of users that visited your store listing who did not have your app installed on any device.
{% enddocs %}

{% docs store_listing_conversion_rate %}
The percentage of store listing visitors who installed your app on a given day.

Note: Does not include visits or installs from users who already have your app installed on another device
{% enddocs %}

{% docs total_active_subscriptions %}
The rolling count of active subscriptions of this type in this country.
{% enddocs %}

{% docs cancelled_subscriptions %}
The daily count of cancelled subscriptions.
{% enddocs %}

{% docs new_subscriptions %}
The daily count of newly purchased subscriptions.
{% enddocs %}

{% docs traffic_source %}
How the user got to your store listing: Google Play search, Third-party referral, Google Play explore, or Other.
{% enddocs %}

{% docs country %} 
Two-letter abbreviation of the country where the user’s Google account is registered. 
{% enddocs %} 

{% docs country_region %}
Two-letter abbreviation of the country or region where the user’s Google account is registered.
{% enddocs %}

{% docs app_version_code %}
Integer value of the version of the app being reported on.
{% enddocs %}

{% docs device %}
Type of device model. May be NULL if users do not consent to being tracked.
{% enddocs %}

{% docs android_os_version %}
Operation System of the android being used. May be NULL if users do not consent to being tracked.
{% enddocs %}

{% docs sku_id %}
Developer-specified unique ID assigned to the ordered product. Subscription order IDs include the renewal cycle number at the end.
{% enddocs %}

{% docs source_relation %}
The source of the record if the unioning functionality is being used. If not this field will be empty.
{% enddocs %}