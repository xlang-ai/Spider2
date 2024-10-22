# Decision Log

In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on a few different questions we came across during development. We've consolidated significant choices we made here, and will continue to update as the package evolves. We are always open to and encourage feedback on these choices, and the package in general.

## Including incomplete recent data
This package does not exclude recent data, though there can be somewhat considerable lags between the data you see in the Google Play UI statistics reports and that in your Google Play connector data. These delays can range from hours to over a week in our experience, and they may be inconsistent across source tables. Note that though there may be non-zero metrics reported in recent records, they still exclude events/users/devices captured in the Google Play UI and may change in the near future. 

## Grouping records with `null` dimensions into daily batches
Some records come from Google Play with `null` dimensions, meaning that the `device`, `country`, `android_os_version`, or `app_version_code` is `null`. This might occur if users have opted out of tracking (though ultimately anonymized data is passed through). 

On a given day, there may be *multiple* records with `null` dimensions. This package batches these `null` records into one per day per app, aggregating metrics when possible. For `ratings` models, the volume of ratings is not provided by the data, as it only provides the daily average and rolling average ratings. Thus, the only aggregation to feasibly use would be an average of averages, which is not a meaningful calculation. To avoid passing through a nonsensical metric, this package nullifies rating values for records with `null` dimensions.