# GA4 - BigQuery Export schema

This article explains the format and schema of the Google Analytics 4 property data and the Google Analytics for Firebase data that is exported to BigQuery.

## Datasets

For each Google Analytics 4 property and each Firebase project that is linked to BigQuery, a single dataset named "analytics_<property_id>" is added to your BigQuery project. Property ID refers to your Analytics Property ID, which you can find in the property settings for your Google Analytics 4 property, and in App Analytics Settings in Firebase. Each Google Analytics 4 property and each app for which BigQuery exporting is enabled will export its data to that single dataset.

## Tables

Within each dataset, a table named `events_YYYYMMDD` is created each day if the Daily export option is enabled.

If the Streaming export option is enabled, a table named`events_intraday_YYYYMMDD`is created. This table is populated continuously as events are recorded throughout the day. This table is deleted at the end of each day once `events_YYYYMMDD` is complete.

Not all devices on which events are triggered send their data to Analytics on the same day the events are triggered. To account for this latency, Analytics will update the daily tables (`events_YYYYMMDD`) with events for those dates for up to three days after the dates of the events. Events will have the correct time stamp regardless of arriving late. Events that arrive after that three-day window are not recorded.

## Columns

Each column in the `events_YYYYMMDD`table represents an event-specific parameter. Note that some parameters are nested within RECORDS, and some RECORDS such as
`[items](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001&sjid=16041154979191290935-EU#items)`
and
`[event_params](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001&sjid=16041154979191290935-EU#event_params)`
are repeatable. Table columns are described below.

### event

The event fields contain information that uniquely identifies an event.

| Field name | Data type | Description |
|---|---|---|
| batch_event_index | INTEGER | A number indicating the sequential order of each event within a batch based on their order of occurrence on the device. |
| batch_ordering_id | INTEGER | A monotonically increasing number that is incremented each time a network request is sent from a given page. |
| batch_page_id | INTEGER | A sequential number assigned to a page that increases for each subsequent page within an engagement. |
| event_date | STRING | The date when the event was logged (YYYYMMDD format in the registered timezone of your app). |
| event_timestamp | INTEGER | The time (in microseconds, UTC) when the event was logged on the client. |
| event_previous_timestamp | INTEGER | The time (in microseconds, UTC) when the event was previously logged on the client. |
| event_name | STRING | The name of the event. |
| event_value_in_usd | FLOAT | The currency-converted value (in USD) of the event's "value" parameter. |
| event_bundle_sequence_id | INTEGER | The sequential ID of the bundle in which these events were uploaded. |
| event_server_timestamp_offset | INTEGER | Timestamp offset between collection time and upload time in micros. |

#### event_params RECORD

The event_params RECORD can store campaign-level and contextual event parameters as well as any user-defined event parameters. The event_params RECORD is repeated for each key that is associated with an event. The set of parameters stored in the event_params RECORD is unique to each implementation. To see the complete list of event parameters for your implementation, query the event parameter list.

| Field name | Data type | Description |
|---|---|---|
| event_params.key | STRING | The name of the event parameter. |
| event_params.value | RECORD | A record containing the event parameter's value. |
| event_params.value.string_value | STRING | If the event parameter is represented by a string, such as a URL or campaign name, it is populated in this field. |
| event_params.value.int_value | INTEGER | If the event parameter is represented by an integer, it is populated in this field. |
| event_params.value.double_value | FLOAT | If the event parameter is represented by a double value, it is populated in this field. |
| event_params.value.float_value | FLOAT | If the event parameter is represented by a floating point value, it is populated in this field. This field is not currently in use. |

#### item_params RECORD

The item_params RECORD can store item parameters as well as any user-defined item parameters. The set of parameters stored in the item_params RECORD is unique to each implementation.

| Field name | Data type | Description |
|---|---|---|
| item_params.key | STRING | The name of the item parameter. |
| item_params.value | RECORD | A record containing the item parameter’s value. |
| item_params.value.string_value | STRING | If the item parameter is represented by a string, it is populated in this field. |
| item_params.value.int_value | INTEGER | If the item parameter is represented by an integer, it is populated in this field. |
| item_params.value.double_value | FLOAT | If the item parameter is represented by a double value, it is populated in this field. |
| item_params.value.float_value | FLOAT | If the item parameter is represented by a floating point value, it is populated in this field. | 

### user

The user fields contain information that uniquely identifies the user associated with the event.

| Field name | Data type | Description |
|---|---|---|
| is_active_user | BOOLEAN | Whether the user was active (True) or inactive (False) at any point in the calendar day Included in only the daily tables ( events_YYYYMMDD) . |
| user_id | STRING | The unique ID assigned to a user. |
| user_pseudo_id | STRING | The pseudonymous id (e.g., app instance ID) for the user. |
| user_first_touch_timestamp | INTEGER | The time (in microseconds) at which the user first opened the app or visited the site. |

#### privacy_info fields

The privacy_info fields contain information based on the consent status of a user when consent mode is enabled .

| Field name | Data type | Description |
|---|---|---|
| privacy_info.ads_storage | STRING | Whether ad targeting is enabled for a user. Possible values: Yes, No, Unset |
| privacy_info.analytics_storage | STRING | Whether Analytics storage is enabled for the user. Possible values: Yes, No, Unset |
| privacy_info.uses_transient_token | STRING | Whether a web user has denied Analytics storage and the developer has enabled measurement without cookies based on transient tokens in server data. Possible values: Yes, No, Unset |

#### user_properties RECORD

The user_properties RECORD contains any user properties that you have set. It is repeated for each key that is associated with a user.

| Field name | Data type | Description |
|---|---|---|
| user_properties.key | STRING | The name of the user property. |
| user_properties.value | RECORD | A record for the user property value. |
| user_properties.value.string_value | STRING | The string value of the user property. |
| user_properties.value.int_value | INTEGER | The integer value of the user property. |
| user_properties.value.double_value | FLOAT | The double value of the user property. |
| user_properties.value.float_value | FLOAT | This field is currently unused. |
| user_properties.value.set_timestamp_micros | INTEGER | The time (in microseconds) at which the user property was last set. |

#### user_ltv RECORD

The user_ltv RECORD contains Lifetime Value information about the user. This RECORD is not populated in intraday tables.

| Field name | Data type | Description |
|---|---|---|
| user_ltv.revenue | FLOAT | The Lifetime Value (revenue) of the user. This field is not populated in intraday tables. |
| user_ltv.currency | STRING | The Lifetime Value (currency) of the user. This field is not populated in intraday tables. | 

### device

The device RECORD contains information about the device from which the event originated.

| Field name | Data type | Description |
|---|---|---|
| device.category | STRING | The device category (mobile, tablet, desktop). |
| device.mobile_brand_name | STRING | The device brand name. |
| device.mobile_model_name | STRING | The device model name. |
| device.mobile_marketing_name | STRING | The device marketing name. |
| device.mobile_os_hardware_model | STRING | The device model information retrieved directly from the operating system. |
| device.operating_system | STRING | The operating system of the device. |
| device.operating_system_version | STRING | The OS version. |
| device.vendor_id | STRING | IDFV (present only if IDFA is not collected). |
| device.advertising_id | STRING | Advertising ID/IDFA. |
| device.language | STRING | The OS language. |
| device.time_zone_offset_seconds | INTEGER | The offset from GMT in seconds. |
| device.is_limited_ad_tracking | BOOLEAN | The device's Limit Ad Tracking setting. On iOS14+, returns false if the IDFA is non-zero. |
| device.web_info.browser | STRING | The browser in which the user viewed content. |
| device.web_info.browser_version | STRING | The version of the browser in which the user viewed content. |
| device.web_info.hostname | STRING | The hostname associated with the logged event. | 

### geo

The geo RECORD contains information about the geographic location where the event was initiated.

| Field name | Data type | Description |
|---|---|---|
| geo.continent | STRING | The continent from which events were reported, based on IP address. |
| geo.sub_continent | STRING | The subcontinent from which events were reported, based on IP address. |
| geo.country | STRING | The country from which events were reported, based on IP address. |
| geo.region | STRING | The region from which events were reported, based on IP address. |
| geo.metro | STRING | The metro from which events were reported, based on IP address. |
| geo.city | STRING | The city from which events were reported, based on IP address. | 

### app_info

The app_info RECORD contains information about the app in which the event was initiated. | Field name | Data type | Description |
|---|---|---|
| app_info.id | STRING | The package name or bundle ID of the app. |
| app_info.firebase_app_id | STRING | The Firebase App ID associated with the app |
| app_info.install_source | STRING | The store that installed the app. |
| app_info.version | STRING | The app's versionName (Android) or short bundle version. | 

### collected_traffic_source

The collected_traffic_source RECORD contains the traffic source data that was collected with the event.

| Field name | Data type | Description |
|---|---|---|
| manual_campaign_id | STRING | The manual campaign id (utm_id) that was collected with the event. |
| manual_campaign_name | STRING | The manual campaign name (utm_campaign) that was collected with the event. |
| manual_source | STRING | The manual campaign source (utm_source) that was collected with the event. Also includes parsed parameters from referral params, not just UTM values. |
| manual_medium | STRING | The manual campaign medium (utm_medium) that was collected with the event. Also includes parsed parameters from referral params, not just UTM values. |
| manual_term | STRING | The manual campaign keyword/term (utm_term) that was collected with the event. |
| manual_content | STRING | The additional manual campaign metadata (utm_content) that was collected with the event. |
| manual_creative_format | STRING | The manual campaign creative format (utm_creative_format) that was collected with the event. |
| manual_marketing_tactic | STRING | The manual campaign marketing tactic (utm_marketing_tactic) that was collected with the event. |
| manual_source_platform | STRING | The manual campaign source platform (utm_source_platform) that was collected with the event. |
| gclid | STRING | The Google click identifier that was collected with the event. |
| dclid | STRING | The DoubleClick Click Identifier for Display and Video 360 and Campaign Manager 360 that was collected with the event. |
| srsltid | STRING | The Google Merchant Center identifier that was collected with the event. | 

### session_traffic_source_last_click

The session_traffic_source_last_click RECORD contains the last-click attributed session traffic source data across Google ads and manual contexts, where available.

| Field Name | Data Type | Description |
|---|---|---|
| session_traffic_source_last_click. manual_campaign.campaign_id | STRING | The ID of the last clicked manual campaign |
| session_traffic_source_last_click. manual_campaign.campaign_name | STRING | The name of the last clicked manual campaign |
| session_traffic_source_last_click. manual_campaign.medium | STRING | The medium of the last clicked manual campaign (e.g., paid search, organic search, email) |
| session_traffic_source_last_click. manual_campaign.term | STRING | The keyword/search term of the last clicked manual campaign |
| session_traffic_source_last_click. manual_campaign.content | STRING | Additional metadata of the last clicked manual campaign |
| session_traffic_source_last_click. manual_campaign.source_platform | STRING | The platform of the last clicked manual campaign (e.g., search engine, social media) |
| session_traffic_source_last_click. manual_campaign.source | STRING | The specific source within the platform of the last clicked manual campaign |
| session_traffic_source_last_click. manual_campaign.creative_format | STRING | The format of the creative of the last clicked manual campaign |
| session_traffic_source_last_click. manual_campaign.marketing_tactic | STRING | The marketing tactic of the last clicked manual campaign |
| session_traffic_source_last_click. google_ads_campaign.customer_id | STRING | The customer ID associated with the Google Ads account |
| session_traffic_source_last_click. google_ads_campaign.account_name | STRING | The name of the Google Ads account |
| session_traffic_source_last_click. google_ads_campaign.campaign_id | STRING | The ID of the Google Ads campaign |
| session_traffic_source_last_click. google_ads_campaign.campaign_name | STRING | The name of the Google Ads campaign |
| session_traffic_source_last_click. google_ads_campaign.ad_group_id | STRING | The ID of the ad group within the Google Ads campaign |
| session_traffic_source_last_click. google_ads_campaign.ad_group_name | STRING | The name of the ad group within the Google Ads campaign | 

### traffic_source

The traffic_source RECORD contains information about the traffic source that first acquired the user. This record is not populated in intraday tables. Note: The traffic_source values do not change if the user interacts with subsequent campaigns after installation.

| Field name | Data type | Description |
|---|---|---|
| traffic_source.name | STRING | Name of the marketing campaign that first acquired the user. This field is not populated in intraday tables. |
| traffic_source.medium | STRING | Name of the medium (paid search, organic search, email, etc.) that first acquired the user. This field is not populated in intraday tables. |
| traffic_source.source | STRING | Name of the network that first acquired the user. This field is not populated in intraday tables. | 

### stream and platform

The stream and platform fields contain information about the stream and the app platform.

| Field name | Data type | Description |
|---|---|---|
| stream_id | STRING | The numeric ID of the data stream from which the event originated. |
| platform | STRING | The data stream platform (Web, IOS or Android) from which the event originated. | 

### ecommerce

This ecommerce RECORD contains information about any ecommerce events that have been setup on a website or app.

| Field name | Data type | Description |
|---|---|---|
| ecommerce.total_item_quantity | INTEGER | Total number of items in this event, which is the sum of items.quantity. |
| ecommerce.purchase_revenue_in_usd | FLOAT | Purchase revenue of this event, represented in USD with standard unit. Populated for purchase event only. |
| ecommerce.purchase_revenue | FLOAT | Purchase revenue of this event, represented in local currency with standard unit. Populated for purchase event only. |
| ecommerce.refund_value_in_usd | FLOAT | The amount of refund in this event, represented in USD with standard unit. Populated for refund event only. |
| ecommerce.refund_value | FLOAT | The amount of refund in this event, represented in local currency with standard unit. Populated for refund event only. |
| ecommerce.shipping_value_in_usd | FLOAT | The shipping cost in this event, represented in USD with standard unit. |
| ecommerce.shipping_value | FLOAT | The shipping cost in this event, represented in local currency. |
| ecommerce.tax_value_in_usd | FLOAT | The tax value in this event, represented in USD with standard unit. |
| ecommerce.tax_value | FLOAT | The tax value in this event, represented in local currency with standard unit. |
| ecommerce.transaction_id | STRING | The transaction ID of the ecommerce transaction. |
| ecommerce.unique_items | INTEGER | The number of unique items in this event, based on item_id, item_name, and item_brand. | 

### items

The items RECORD contains information about items included in an event. It is repeated for each item.

| Field name | Data type | Description |
|---|---|---|
| items.item_id | STRING | The ID of the item. |
| items.item_name | STRING | The name of the item. |
| items.item_brand | STRING | The brand of the item. |
| items.item_variant | STRING | The variant of the item. |
| items.item_category | STRING | The category of the item. |
| items.item_category2 | STRING | The sub category of the item. |
| items.item_category3 | STRING | The sub category of the item. |
| items.item_category4 | STRING | The sub category of the item. |
| items.item_category5 | STRING | The sub category of the item. |
| items.price_in_usd | FLOAT | The price of the item, in USD with standard unit. |
| items.price | FLOAT | The price of the item in local currency. |
| items.quantity | INTEGER | The quantity of the item. Quantity set to 1 if not specified. |
| items.item_revenue_in_usd | FLOAT | The revenue of this item, calculated as price_in_usd * quantity. It is populated for purchase events only, in USD with standard unit. |
| items.item_revenue | FLOAT | The revenue of this item, calculated as price * quantity. It is populated for purchase events only, in local currency with standard unit. |
| items.item_refund_in_usd | FLOAT | The refund value of this item, calculated as price_in_usd * quantity. It is populated for refund events only, in USD with standard unit. |
| items.item_refund | FLOAT | The refund value of this item, calculated as price * quantity. It is populated for refund events only, in local currency with standard unit. |
| items.coupon | STRING | Coupon code applied to this item. |
| items.affiliation | STRING | A product affiliation to designate a supplying company or brick and mortar store location. |
| items.location_id | STRING | The location associated with the item. |
| items.item_list_id | STRING | The ID of the list in which the item was presented to the user. |
| items.item_list_name | STRING | The name of the list in which the item was presented to the user. |
| Items.item_list_index | STRING | The position of the item in a list. |
| items.promotion_id | STRING | The ID of a product promotion. |
| items.promotion_name | STRING | The name of a product promotion. |
| items.creative_name | STRING | The name of a creative used in a promotional spot. |
| items.creative_slot | STRING | The name of a creative slot. |

#### item_params RECORD

The item_params RECORD stores the custom item parameters that you defined. Note that predefined item parameters like item_id, item_name etc, are not included here, instead they are exported as explicit fields. The set of parameters stored in the item_params RECORD is unique to each implementation. To learn more about ecommerce implementations and the Google Analytics 4 items array, see Measure ecommerce .

| Field name | Data type | Description |
|---|---|---|
| items.item_params.key | STRING | The name of the item parameter. |
| items.item_params.value | RECORD | A record containing the item parameter’s value. |
| items.item_params.value.string_value | STRING | If the item parameter is represented by a string, it is populated in this field. |
| items.item_params.value.int_value | INTEGER | If the item parameter is represented by an integer, it is populated in this field. |
| items.item_params.value.double_value | FLOAT | If the item parameter is represented by a double value, it is populated in this field. |
| items.item_params.value.float_value | FLOAT | If the item parameter is represented by a floating point value, it is populated in this field. | 

## Rows

Data for a single event may be represented in one or multiple rows, depending on whether it contains repeated RECORDS. A `page_view` event with multiple
`[event_params](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001&sjid=16041154979191290935-EU#event_params)`,
for example, would look similar to the following table. The initial row contains the event name, date, timestamp and other non-repeated data items. The
`[event_params](https://support.google.com/analytics/answer/7029846?hl=en&ref_topic=9359001&sjid=16041154979191290935-EU#event_params)`
RECORD is repeated for each parameter associated with the event. These repeated RECORDS are populated in subsequent rows directly under the initial event row.

| event_date | event_timestamp | event_name | event_params.key | event_params_value.string_value |
|---|---|---|---|---|
| 20220222 | 1643673600483790 | page_view | page_location | https://example.com |
| - | - | - | page_title | Home |
| - | - | - | medium | referral |
| - | - | - | source | google |
| - | - | - | page_referrer | https://www.google.com |
| - | - | - | parameters... | values... |