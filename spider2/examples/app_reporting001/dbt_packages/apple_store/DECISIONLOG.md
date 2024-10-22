# Decision Log

In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on a few different questions we came across during development. We've consolidated significant choices we made here, and will continue to update as the package evolves. 

## Not including `impressions_unique_device`, `page_views_unique_device`, `active_devices_last_30_days` in `apple_store__overview_report`
We chose to not include these metrics in the `apple_store__overview_report` since we are taking these report metrics directly from the Apple App Store and we do not have insight into how to account for duplication across source types. 

## Not including `impressions_unique_device`, `page_views_unique_device`, `active_devices_last_30_days` in `apple_store__source_type_report`
We chose to not include these metrics in the `apple_store__overview_report` since we are taking these report metrics directly from the Apple App Store and we do not have insight into how to account for duplication across device types. 

## Subscriptions Report
This model will **not** tie out to the Apple UI's Subscriptions as there currently isn't a clear way to map the current subscription events to how Apple calculates and group their events together. [(source)](https://help.apple.com/app-store-connect/#/itc484ef82a0)