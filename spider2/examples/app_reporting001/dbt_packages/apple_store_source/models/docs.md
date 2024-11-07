{% docs _fivetran_synced %} Timestamp of when Fivetran synced a record. {% enddocs %}

{% docs account_id %} Sales Account ID associated with the app name or app ID. {% enddocs%}

{% docs account_name %} Sales Account Name associated with the Sales Account ID, app name or app ID. {% enddocs %}

{% docs active_devices %} The count of active_device is the count of devices that ran the app at least one time and for at least two seconds on a given day (User Opt-In only); this metric is presumed to be de-duplicated daily as received from the source data, therefore, aggregating over a span of days is better done in the UI. A value of 0 indicates there were 0 active devices or no value from the source report that day. {% enddocs %}

{% docs active_devices_last_30_days %} The count of active_devices_last_30_days is the count of devices that ran the app at least one time and for at least two seconds on the date_day of the report minus 30 days (User Opt-In only); this metric is presumed to be de-duplicated daily as received from the source data, therefore, aggregating over a span of days is better done in the UI. A value of 0 indicates there were 0 active devices last 30 days or no value from the source report that day.{% enddocs %}

{% docs active_free_trial_introductory_offer_subscriptions %} Total number of introductory offer subscriptions currently in a free trial. {% enddocs %}

{% docs active_pay_as_you_go_introductory_offer_subscriptions %} Total number of introductory offer subscriptions currently with a pay as you go introductory price. {% enddocs %}

{% docs active_pay_up_front_introductory_offer_subscriptions %} Total number of introductory offer subscriptions currently with a pay up front introductory price. {% enddocs %}

{% docs active_standard_price_subscriptions %} Total number of auto-renewable standard paid subscriptions currently active, excluding free trials, 
subscription offers, introductory offers, and marketing opt-ins. Subscriptions are active during the period for which the customer has paid without cancellation. {% enddocs %}

{% docs alternative_country_name %} Due to differences in the official ISO country names and Apple's naming convention, we've added an alternative territory name that will allow us to join reports and infer ISO fields. {% enddocs %}

{% docs app_id %} Application ID. {% enddocs%}

{% docs app_name %} Application Name. {% enddocs %}

{% docs app_version %} The app version of the app that the user is engaging with. {% enddocs %}

{% docs country %} The country associated with the subscription event metrics and subscription summary metric(s). This country code maps to ISO-3166 Alpha-2. {% enddocs %}

{% docs country_code_alpha_2 %} The 2 character ISO-3166 country code. ([Original Source](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv)) {% enddocs%}

{% docs country_code_alpha_3 %} The 3 character ISO-3166 country code. ([Original Source](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv)) {% enddocs%}

{% docs country_code_numeric %} The 3 digit ISO-3166 country code. ([Original Source](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv)) {% enddocs%}

{% docs country_name %} The ISO-3166 English country name. ([Original Source](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv)) {% enddocs%}

{% docs crashes %} The number of recorded crashes experienced (User Opt-In only); a value of 0 indicates there were 0 crash reports or no value from the source report that day. {% enddocs %}

{% docs date_day %} The date of the report and respective recorded metric(s); follows the format `YYYY-MM-DD`. {% enddocs %}

{% docs deletions %} A deletion occurs when a user removes your app from their device (User Opt-In only). Data from resetting or erasing a device’s content and settings is not included. A value of 0 indicates there were 0 deletions or no value from the source report that day. {% enddocs %}

{% docs device %} Device type associated with the respective metric(s). {% enddocs %}

{% docs event %} The subscription event associated with the respective metric(s). {% enddocs %}

{% docs first_time_downloads %} The number of first time downloads for your app; credit is attributed to the referring app, website, or App Clip of the first time download. {% enddocs %}

{% docs impressions %} The number of times your app was viewed in the App Store for more than one second. This includes search results, Featured, Explore, Top Charts and App Product Page views. (Source: [BusinessofApps](https://www.businessofapps.com/insights/understanding-the-app-store-metrics/#:~:text=Impressions%20%E2%80%93%20%E2%80%9CThe%20number%20of%20times,was%20clicked%20on%20and%20viewed.)) {% enddocs %}

{% docs impressions_unique_device %} The number of unique devices that have viewed your app for more than one second on on the Today, Games, Apps, Featured, Explore, Top Charts, Search tabs of the App Store and App Product Page views. This metric is presumed to be de-duplicated daily as received from the source data, therefore, aggregating over a span of days is better done in the UI. {% enddocs %}

{% docs installations%} An installation event is when the user opens the App after they've downloaded it (User Opt-In only). If the App was downloaded but not opened or opened offline, this will not count; if the user opts out of sending data back to Apple, there will also be no data here. A value of 0 indicates there were 0 installations or no value from the source report that day. {% enddocs %}

{% docs page_views %} The total number of times your App Store product page was clicked and viewed; when a user taps on a link from an app, website or App Clip card that brings them to your App Store product page, the immediate product page_view is attributed to the referring app, website, or App Clip. (Sources: [Apple](https://help.apple.com/app-store-connect/#/itcf19c873df), [BusinessofApps](https://www.businessofapps.com/insights/understanding-the-app-store-metrics/#:~:text=Impressions%20%E2%80%93%20%E2%80%9CThe%20number%20of%20times,was%20clicked%20on%20and%20viewed.)) {% enddocs %}

{% docs page_views_unique_device %} The number of unique devices that have viewed your App Store product page; this metric is presumed to be de-duplicated daily as received from the source data, therefore, aggregating over a span of days is better done in the UI. {% enddocs %}

{% docs platform_version %} The platform version of the device engaging with your app. {% enddocs %}

{% docs quantity %} The number of occurrences of a given subscription event. {% enddocs %}

{% docs sessions %} Sessions is the count of the number of times the app has been used for at least two seconds (User Opt-In only). If the app is in the background and is later used again, that counts as another session. A value of 0 indicates there were 0 sessions or no value from the source report that day. {% enddocs %}

{% docs redownloads %} The count of redownloads where a redownload occurs when a user who previously downloaded your app adds it to their device again (User Opt-In only); credit is attributed to the source recorded when a user tapped to download/launch your app for the first time. A value of 0 indicates there were 0 redownloads or no value from the source report that day. {% enddocs %}

{% docs region %} The UN Statistics region name assignment. ([Original Source](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv)) {% enddocs %}

{% docs region_code %} The UN Statistics region numerical code assignment. ([Original Source](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv)) {% enddocs %}

{% docs source_type %} A source is counted when a customer follows a link to your App Store product page. 
There are 8 types of sources: App Store Browse, App Store Search, App Referrers, Web Referrers, App Clips, Unavailable, Institutional Purchases, and Null. Null is the default value for data that does not provide source types, including: crashes, subscription events and subscription summary.
More information can be found in the Apple App Store developer [docs](https://developer.apple.com/help/app-store-connect/view-app-analytics/view-acquisition-sources/).
{% enddocs %}

{% docs state %} The state associated with the subscription event metrics or subscription summary metrics. {% enddocs %}

{% docs sub_region %} The UN Statistics sub-region name. ([Original Source](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv)) {% enddocs%}

{% docs sub_region_code %} The UN Statistics sub-region numerical code. ([Original Source](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/blob/master/all/all.csv)) {% enddocs %}

{% docs subscription_name %} The subscription name associated with the subscription event metric or subscription summary metric. {% enddocs %}

{% docs territory %} The territory (aka country) full name associated with the report's respective metric(s). {% enddocs %}

{% docs total_downloads %} Total Downloads is the sum of Redownloads and First Time Downloads. {% enddocs %}

{% docs territory_long %} Either the alternative country name, or the country name if the alternative doesn't exist. {% enddocs %}

{% docs source_relation %}The source of the record if the unioning functionality is being used. If it is not this field will be empty.{% enddocs %}