## Documents about Google Analytics Sample - ga_sessions

This article explains the format and schema of the data that is imported into BigQuery.

## Datasets

For each Analytics view that is enabled for BigQuery integration, a dataset is added using the view ID as the name.

## Tables

Within each dataset, a table is imported for each day of export. Daily tables have the format "ga\_sessions\_YYYYMMDD".

Intraday data is imported at least three times a day. Intraday tables have the format "ga\_sessions\_intraday\_YYYYMMDD". During the same day, each import of intraday data overwrites the previous import in the same table.

When the daily import is complete, the intraday table from the previous day is deleted. For the current day, until the first intraday import, there is no intraday table. If an intraday-table write fails, then the previous day's intraday table is preserved.

Data for the current day is not final until the daily import is complete. You may notice differences between intraday and daily data based on active user sessions that cross the time boundary of last intraday import.

## Rows

Each row within a table corresponds to a session in Analytics 360.

## Columns

The columns within the export are listed below. In BigQuery, some columns may have nested fields and messages within them.

| Field Name | Data Type | Description |
| --- | --- | --- |
| clientId | STRING | Unhashed version of the Client ID for a given user associated with any given visit/session. |
| fullVisitorId | STRING | The unique visitor ID. |
| visitorId | NULL | This field is deprecated. Use "fullVisitorId" instead. |
| userId | STRING | Overridden User ID sent to Analytics. |
| visitNumber | INTEGER | The session number for this user. If this is the first session, then this is set to 1. |
| visitId | INTEGER | An identifier for this session. This is part of the value usually stored as the _utmb cookie. This is only unique to the user. For a completely unique ID, you should use a combination of fullVisitorId and visitId. |
| visitStartTime | INTEGER | The timestamp (expressed as POSIX time). |
| date | STRING | The date of the session in YYYYMMDD format. |
| totals | RECORD | This section contains aggregate values across the session. |
| totals.bounces | INTEGER | Total bounces (for convenience). For a bounced session, the value is 1, otherwise it is null. |
| totals.hits | INTEGER | Total number of hits within the session. |
| totals.newVisits | INTEGER | Total number of new users in session (for convenience). If this is the first visit, this value is 1, otherwise it is null. |
| totals.pageviews | INTEGER | Total number of pageviews within the session. |
| totals.screenviews | INTEGER | Total number of screenviews within the session. |
| totals.sessionQualityDim | INTEGER | An estimate of how close a particular session was to transacting, ranging from 1 to 100, calculated for each session. A value closer to 1 indicates a low session quality, or far from transacting, while a value closer to 100 indicates a high session quality, or very close to transacting. A value of 0 indicates that Session Quality is not calculated for the selected time range. |
| totals.timeOnScreen | INTEGER | The total time on screen in seconds. |
| totals.timeOnSite | INTEGER | Total time of the session expressed in seconds. |
| totals.totalTransactionRevenue | INTEGER | Total transaction revenue, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| totals.transactionRevenue | INTEGER | This field is deprecated. Use "totals.totalTransactionRevenue" instead (see above). |
| totals.transactions | INTEGER | Total number of ecommerce transactions within the session. |
| totals.UniqueScreenViews | INTEGER | Total number of unique screenviews within the session. |
| totals.visits | INTEGER | The number of sessions (for convenience). This value is 1 for sessions with interaction events. The value is null if there are no interaction events in the session. |
| trafficSource | RECORD | This section contains information about the Traffic Source from which the session originated. |
| trafficSource.adContent | STRING | The ad content of the traffic source. Can be set by the utm_content URL parameter. |
| trafficSource.adwordsClickInfo | RECORD | This section contains information about the Google Ads click info if there is any associated with this session. Analytics uses the last non-direct click model. |
| trafficSource.<br>      adwordsClickInfo.adGroupId | INTEGER | The Google ad-group ID. |
| trafficSource.<br>      adwordsClickInfo.adNetworkType | STRING | Network Type. Takes one of the following values: {“Google Search", "Content", "Search partners", "Ad Exchange", "Yahoo Japan Search", "Yahoo Japan AFS", “unknown”} |
| trafficSource.<br>      adwordsClickInfo.campaignId | INTEGER | The Google Ads campaign ID. |
| trafficSource.<br>      adwordsClickInfo.creativeId | INTEGER | The Google ad ID. |
| trafficSource.<br>      adwordsClickInfo.criteriaId | INTEGER | The ID for the targeting criterion. |
| trafficSource.<br>      adwordsClickInfo.criteriaParameters | STRING | Descriptive string for the targeting criterion. |
| trafficSource.<br>      adwordsClickInfo.customerId | INTEGER | The Google Ads Customer ID. |
| trafficSource.<br>      adwordsClickInfo.gclId | STRING | The Google Click ID. |
| trafficSource.<br>      adwordsClickInfo.isVideoAd | BOOLEAN | True if it is a Trueview video ad. |
| trafficSource.<br>      adwordsClickInfo.page | INTEGER | Page number in search results where the ad was shown. |
| trafficSource.<br>      adwordsClickInfo.slot | STRING | Position of the Ad. Takes one of the following values:{“RHS", "Top"} |
| trafficSource.<br>      adwordsClickInfo.targetingCriteria | RECORD | Google Ads targeting criteria for a click. There are multiple types of targeting criteria, but should have only one value for each criterion. |
| trafficSource.<br>      adwordsClickInfo.targetingCriteria.<br>      boomUserlistId | INTEGER | Remarketing list ID (if any) in Google Ads, derived from matching_criteria in click record. |
| trafficSource.campaign | STRING | The campaign value. Usually set by the utm_campaign URL parameter. |
| trafficSource.campaignCode | STRING | Value of the utm_id campaign tracking parameter, used for manual campaign tracking. |
| trafficSource.isTrueDirect | BOOLEAN | True if the source of the session was Direct (meaning the user typed the name of your website URL into the browser or came to your site via a bookmark), This field will also be true if 2 successive but distinct sessions have exactly the same campaign details. Otherwise NULL. |
| trafficSource.keyword | STRING | The keyword of the traffic source, usually set when the trafficSource.medium is "organic" or "cpc". Can be set by the utm_term URL parameter. |
| trafficSource.medium | STRING | The medium of the traffic source. Could be "organic", "cpc", "referral", or the value of the utm_medium URL parameter. |
| trafficSource.referralPath | STRING | If trafficSource.medium is "referral", then this is set to the path of the referrer. (The host name of the referrer is in trafficSource.source.) |
| trafficSource.source | STRING | The source of the traffic source. Could be the name of the search engine, the referring hostname, or a value of the utm_source URL parameter. |
| socialEngagementType | STRING | Engagement type, either "Socially Engaged" or "Not Socially Engaged". |
| channelGrouping | STRING | The Default Channel Group associated with an end user's session for this View. |
| device | RECORD | This section contains information about the user devices. |
| device.browser | STRING | The browser used (e.g., "Chrome" or "Firefox"). |
| device.browserSize | STRING | The viewport size of users' browsers. This captures the initial dimensions of the viewport in pixels and is formatted as width x height, for example, 1920x960. |
| device.browserVersion | STRING | The version of the browser used. |
| device.deviceCategory | STRING | The type of device (Mobile, Tablet, Desktop). |
| device.mobileDeviceInfo | STRING | The branding, model, and marketing name used to identify the mobile device. |
| device.mobileDeviceMarketingName | STRING | The marketing name used for the mobile device. |
| device.mobileDeviceModel | STRING | The mobile device model. |
| device.mobileInputSelector | STRING | Selector (e.g., touchscreen, joystick, clickwheel, stylus) used on the mobile device. |
| device.operatingSystem | STRING | The operating system of the device (e.g., "Macintosh" or "Windows"). |
| device.operatingSystemVersion | STRING | The version of the operating system. |
| device.isMobile<br><br>      This field is deprecated. Use device.deviceCategory instead. | BOOLEAN | If the user is on a mobile device, this value is true, otherwise false. |
| device.mobileDeviceBranding | STRING | The brand or manufacturer of the device. |
| device.flashVersion | STRING | The version of the Adobe Flash plugin that is installed on the browser. |
| device.javaEnabled | BOOLEAN | Whether or not Java is enabled in the browser. |
| device.language | STRING | The language the device is set to use. Expressed as the IETF language code. |
| device.screenColors | STRING | Number of colors supported by the display, expressed as the bit-depth (e.g., "8-bit", "24-bit", etc.). |
| device.screenResolution | STRING | The resolution of the device's screen, expressed in pixel width x height (e.g., "800x600"). |
| customDimensions | RECORD | This section contains any user-level or session-level custom dimensions that are set for a session. This is a repeated field and has an entry for each dimension that is set. |
| customDimensions.index | INTEGER | The index of the custom dimension. |
| customDimensions.value | STRING | The value of the custom dimension. |
| geoNetwork | RECORD | This section contains information about the geography of the user. |
| geoNetwork.continent | STRING | The continent from which sessions originated, based on IP address. |
| geoNetwork.subContinent | STRING | The sub-continent from which sessions originated, based on IP address of the visitor. |
| geoNetwork.country | STRING | The country from which sessions originated, based on IP address. |
| geoNetwork.region | STRING | The region from which sessions originate, derived from IP addresses. In the U.S., a region is a state, such as New York. |
| geoNetwork.metro | STRING | The Designated Market Area (DMA) from which sessions originate. |
| geoNetwork.city | STRING | Users' city, derived from their IP addresses or Geographical IDs. |
| geoNetwork.cityId | STRING | Users' city ID, derived from their IP addresses or Geographical IDs. |
| geoNetwork.latitude | STRING | The approximate latitude of users' city, derived from their IP addresses or Geographical IDs. Locations north of the equator have positive latitudes and locations south of the equator have negative latitudes. |
| geoNetwork.longitude | STRING | The approximate longitude of users' city, derived from their IP addresses or Geographical IDs. Locations east of the prime meridian have positive longitudes and locations west of the prime meridian have negative longitudes. |
| geoNetwork.networkDomain | STRING | [No longer supported]<br>The domain name of user's ISP, derived from the domain name registered to the ISP's IP address. |
| geoNetwork.networkLocation | STRING | [No longer supported]<br>The names of the service providers used to reach the property. For example, if most users of the website come via the major cable internet service providers, its value will be these service providers' names. |
| hits | RECORD | This row and nested fields are populated for any and all types of hits. |
| hits.dataSource | STRING | The data source of a hit. By default, hits sent from analytics.js are reported as "web" and hits sent from the mobile SDKs are reported as "app". |
| hits.sourcePropertyInfo | RECORD | This section contains information about source property for rollup properties |
| hits.sourcePropertyInfo.<br>      sourcePropertyDisplayName | STRING | Source property display name of Roll-Up Properties. This is valid for only Roll-Up Properties. |
| hits.sourcePropertyInfo.<br>      sourcePropertyTrackingId | STRING | Source property tracking ID of roll-up properties. This is valid for only roll-up properties. |
| hits.eCommerceAction | RECORD | This section contains all of the ecommerce hits that occurred during the session. This is a repeated field and has an entry for each hit that was collected. |
| hits.eCommerceAction.action_type | STRING | The action type. Click through of product lists = 1, Product detail views = 2, Add product(s) to cart = 3, Remove product(s) from cart = 4, Check out = 5, Completed purchase = 6, Refund of purchase = 7, Checkout options = 8, Unknown = 0.<br>Usually this action type applies to all the products in a hit, with the following exception: when hits.product.isImpression = TRUE, the corresponding product is a product impression that is seen while the product action is taking place (i.e., a "product in list view"). |
| hits.eCommerceAction.option | STRING | This field is populated when a checkout option is specified. For example, a shipping option such as option = 'Fedex'. |
| hits.eCommerceAction.step | INTEGER | This field is populated when a checkout step is specified with the hit. |
| hits.exceptionInfo.exceptions | INTEGER | The number of exceptions sent to Google Analytics. |
| hits.exceptionInfo.fatalExceptions | INTEGER | The number of exceptions sent to Google Analytics where isFatal is set to true. |
| hits.experiment | RECORD | This row and the nested fields are populated for each hit that contains data for an experiment. |
| hits.experiment.experimentId | STRING | The ID of the experiment. |
| hits.experiment.experimentVariant | STRING | The variation or combination of variations present in a hit for an experiment. |
| hits.hitNumber | INTEGER | The sequenced hit number. For the first hit of each session, this is set to 1. |
| hits.hour | INTEGER | The hour in which the hit occurred (0 to 23). |
| hits.isSecure | BOOLEAN | This field is deprecated. |
| hits.isEntrance | BOOLEAN | If this hit was the first pageview or screenview hit of a session, this is set to true. |
| hits.isExit | BOOLEAN | If this hit was the last pageview or screenview hit of a session, this is set to true.<br>There is no comparable field for a Google Analytics 4 property. |
| hits.isInteraction | BOOLEAN | If this hit was an interaction, this is set to true. If this was a non-interaction hit (i.e., an event with interaction set to false), this is false. |
| hits.latencyTracking | RECORD | This section contains information about events in the Navigation Timing API. |
| hits.latencyTracking.domainLookupTime | INTEGER | The total time (in milliseconds) all samples spent in DNS lookup for this page. |
| hits.latencyTracking.domContentLoadedTime | INTEGER | The time (in milliseconds), including the network time from users' locations to the site's server, the browser takes to parse the document and execute deferred and parser-inserted scripts (DOMContentLoaded). |
| hits.latencyTracking.domInteractiveTime | INTEGER | The time (in milliseconds), including the network time from users' locations to the site's server, the browser takes to parse the document (DOMInteractive). |
| hits.latencyTracking.domLatencyMetricsSample | INTEGER | Sample set (or count) of pageviews used to calculate the averages for site speed DOM metrics. |
| hits.latencyTracking.pageDownloadTime | INTEGER | The total time (in milliseconds) to download this page among all samples. |
| hits.latencyTracking.pageLoadSample | INTEGER | The sample set (or count) of pageviews used to calculate the average page load time. |
| hits.latencyTracking.pageLoadTime | INTEGER | Total time (in milliseconds), from pageview initiation (e.g., a click on a page link) to page load completion in the browser, the pages in the sample set take to load. |
| hits.latencyTracking.redirectionTime | INTEGER | The total time (in milliseconds) all samples spent in redirects before fetching this page. If there are no redirects, this is 0. |
| hits.latencyTracking.serverConnectionTime | INTEGER | Total time (in milliseconds) all samples spent in establishing a TCP connection to this page. |
| hits.latencyTracking.serverResponseTime | INTEGER | The total time (in milliseconds) the site's server takes to respond to users' requests among all samples; this includes the network time from users' locations to the server. |
| hits.latencyTracking.speedMetricsSample | INTEGER | The sample set (or count) of pageviews used to calculate the averages of site speed metrics. |
| hits.latencyTracking.userTimingCategory | STRING | For easier reporting purposes, this is used to categorize all user timing variables into logical groups. |
| hits.latencyTracking.userTimingLabel | STRING | The name of the resource's action being tracked. |
| hits.latencyTracking.userTimingSample | INTEGER | The number of hits sent for a particular userTimingCategory, userTimingLabel, or userTimingVariable. |
| hits.latencyTracking.userTimingValue | INTEGER | Total number of milliseconds for user timing. |
| hits.latencyTracking.userTimingVariable | STRING | Variable used to add flexibility to visualize user timings in the reports. |
| hits.minute | INTEGER | The minute in which the hit occurred (0 to 59). |
| hits.product.isImpression | BOOLEAN | TRUE if at least one user viewed this product (i.e., at least one impression) when it appeared in the product list. |
| hits.product.isClick | BOOLEAN | Whether users clicked this product when it appeared in the product list. |
| hits.product.customDimensions | RECORD | This section is populated for all hits containing product scope Custom Dimensions. |
| hits.product.customDimensions.index | INTEGER | The product scope Custom Dimensions index. |
| hits.product.customDimensions.value | STRING | The product scope Custom Dimensions value. |
| hits.product.customMetrics | RECORD | This section is populated for all hits containing product scope Custom Metrics. |
| hits.product.customMetrics.index | INTEGER | The product scope Custom Metrics index. |
| hits.product.customMetrics.value | INTEGER | The product scope Custom Metrics value. |
| hits.product.productListName | STRING | Name of the list in which the product is shown, or in which a click occurred. For example, "Home Page Promotion", "Also Viewed", "Recommended For You", "Search Results List", etc. |
| hits.product.productListPosition | INTEGER | Position of the product in the list in which it is shown. |
| hits.publisher.<br>      adsenseBackfillDfpClicks | INTEGER | The number of clicks on AdSense ads that served as Google Ad Manager backfill. |
| hits.publisher.<br>      adsenseBackfillDfpImpressions | INTEGER | The number of AdSense ad impressions that were served as Google Ad Manager backfill. |
| hits.publisher.<br>      adsenseBackfillDfpMatchedQueries | INTEGER | The number of ad requests where AdSense was trafficked as backfill and returned an ad creative to the page. |
| hits.publisher.<br>      adsenseBackfillDfpMeasurableImpressions | INTEGER | The number of ad impressions filled by AdSense that viewability measurements were able to take into account (includes both in-view and not-in-view ads). |
| hits.publisheradsenseBackfillDfpPagesViewed | INTEGER | The number of Google Analytics pageviews where Google Ad Manager recorded AdSense revenue. |
| hits.publisher.adsenseBackfillDfpQueries | INTEGER | The number of ad requests made to AdSense by Google Ad Manager. |
| hits.publisher.<br>      adsenseBackfillDfpRevenueCpc | INTEGER | The CPC revenue associated with the resultant AdSense ad clicks. |
| hits.publisher.<br>      adsenseBackfillDfpRevenueCpm | INTEGER | The CPM revenue associated with the served AdSense ad impressions. |
| hits.publisher.<br>      adsenseBackfillDfpViewableImpressions | INTEGER | The number of AdSense impressions that met Google Ad Manager’s viewability standard. |
| hits.publisher.adxBackfillDfpClicks | INTEGER | The number of clicks on Google Ad Manager ads served as Google Ad Manager backfill. |
| hits.publisher.<br>      adxBackfillDfpImpressions | INTEGER | The number of Google Ad Manager ad impressions that were served as Google Ad Manager backfill. |
| hits.publisher.<br>      adxBackfillDfpMatchedQueries | INTEGER | The number of ad requests where Google Ad Manager was trafficked as backfill and returned an ad creative to the page. |
| hits.publisher.<br>      adxBackfillDfpMeasurableImpressions | INTEGER | The number of ad impressions filled by Google Ad Manager that viewability measurements are able to take into account (includes both in-view and not-in-view ads). |
| hits.publisher.<br>      adxBackfillDfpPagesViewed | INTEGER | The number of Google Analytics pageviews where Google Ad Manager recorded revenue. |
| hits.publisher.<br>      adxBackfillDfpQueries | INTEGER | The number of ad requests made to Google Ad Manager by Google Ad Manager. |
| hits.publisher.<br>      adxBackfillDfpRevenueCpc | INTEGER | The CPC revenue associated with the resultant Google Ad Manager ad clicks. |
| hits.publisher.<br>      adxBackfillDfpRevenueCpm | INTEGER | The CPM revenue associated with the served Google Ad Manager ad impressions. |
| hits.publisher.<br>      adxBackfillDfpViewableImpressions | INTEGER | The number of Google Ad Manager impressions that met Google Ad Manager’s viewability standard. |
| hits.publisher.dfpAdGroup | STRING | The Google Ad Manager Line Item ID of the ad that served. |
| hits.publisher.dfpAdUnits | STRING | The IDs of the Google Ad Manager Ad Units present in the ad request. |
| hits.publisher.dfpClicks | INTEGER | The number of times Google Ad Manager ads were clicked. |
| hits.publisher.dfpImpressions | INTEGER | A Google Ad Manager ad impression is reported whenever an individual ad is displayed. For example, when a page with two ad units is viewed once, we display two impressions. |
| hits.publisher.dfpMatchedQueries | INTEGER | The number of ad requests where a creative was returned to the page. |
| hits.publisher.dfpMeasurableImpressions | INTEGER | The number of ad impressions that viewability measurements are able to take into account (includes both in-view and not-in-view ads). |
| hits.publisher.dfpNetworkId | STRING | The Google Ad Manager network ID that the ad request was sent to. |
| hits.publisher.dfpPagesViewed | INTEGER | The number of Google Analytics pageviews where Google Ad Manager recorded revenue. |
| hits.publisher.dfpQueries | INTEGER | The number of ad requests made to Google Ad Manager. |
| hits.publisher.dfpRevenueCpc | INTEGER | The CPC revenue associated with the resultant ad clicks, based on the rate-field value for each clicked ad in Google Ad Manager. |
| hits.publisher.dfpRevenueCpm | INTEGER | The CPM revenue associated with the served ad impressions, based on the rate-field value for each served ad in Google Ad Manager. |
| hits.publisher.dfpViewableImpressions | INTEGER | The number of impressions that met Google Ad Manager’s viewability standard. |
| hits.time | INTEGER | The number of milliseconds after the visitStartTime when this hit was registered. The first hit has a hits.time of 0 |
| hits.transaction.transactionCoupon | STRING | The coupon code associated with the transaction. |
| hits.referrer | STRING | The referring page, if the session has a goal completion or transaction. If this page is from the same domain, this is blank. |
| hits.refund | RECORD | This row and nested fields are populated for each hit that contains Enhanced Ecommerce REFUND information. |
| hits.refund.localRefundAmount | INTEGER | Refund amount in local currency, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.refund.refundAmount | INTEGER | Refund amount, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.social | RECORD | This section is populated for each hit with type = "SOCIAL". |
| hits.social.hasSocialSourceReferral | STRING | A string, either Yes or No, that indicates whether sessions to the property are from a social source. |
| hits.social.socialInteractionAction | STRING | The social action passed with the social tracking code (Share, Tweet, etc.). |
| hits.social.socialInteractionNetwork | STRING | The the network passed with the social tracking code, e.g., Twitter. |
| hits.social.socialInteractionNetworkAction | STRING | For social interactions, this represents the social network being tracked. |
| hits.social.socialInteractions | INTEGER | The total number of social interactions. |
| hits.social.socialInteractionTarget | STRING | For social interactions, this is the URL (or resource) which receives the social network action. |
| hits.social.socialNetwork | STRING | The social network name. This is related to the referring social network for traffic sources; e.g., Blogger. |
| hits.social.uniqueSocialInteractions | INTEGER | The number of sessions during which the specified social action(s) occurred at least once. This is based on the the unique combination of socialInteractionNetwork, socialInteractionAction, and socialInteractionTarget. |
| hits.type | STRING | The type of hit. One of: "PAGE", "TRANSACTION", "ITEM", "EVENT", "SOCIAL", "APPVIEW", "EXCEPTION".<br>Timing hits are considered an event type in the Analytics backend. When you query time-related fields (e.g., hits.latencyTracking.pageLoadTime), choose hits.type as Event if you want to use hit.type in your queries. |
| hits.page | RECORD | This section is populated for each hit with type = "PAGE". |
| hits.page.pagePath | STRING | The URL path of the page. |
| hits.page.pagePathLevel1 | STRING | This dimension rolls up all the page paths in the 1st hierarchical level in pagePath. |
| hits.page.pagePathLevel2 | STRING | This dimension rolls up all the page paths in the 2nd hierarchical level in pagePath. |
| hits.page.pagePathLevel3 | STRING | This dimension rolls up all the page paths in the 3d hierarchical level in pagePath. |
| hits.page.pagePathLevel4 | STRING | This dimension rolls up all the page paths into hierarchical levels. Up to 4 pagePath levels may be specified. All additional levels in the pagePath hierarchy are also rolled up in this dimension. |
| hits.page.hostname | STRING | The hostname of the URL. |
| hits.page.pageTitle | STRING | The page title. |
| hits.page.searchKeyword | STRING | If this was a search results page, this is the keyword entered. |
| hits.product | RECORD | This row and nested fields will be populated for each hit that contains Enhanced Ecommerce PRODUCT data. |
| hits.product.localProductPrice | INTEGER | The price of the product in local currency, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.product.localProductRefundAmount | INTEGER | The amount processed as part of a refund for a product in local currency, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.product.localProductRevenue | INTEGER | The revenue of the product in local currency, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.product.productBrand | STRING | The brand associated with the product. |
| hits.product.productPrice | INTEGER | The price of the product, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.product.productQuantity | INTEGER | The quantity of the product purchased. |
| hits.product.productRefundAmount | INTEGER | The amount processed as part of a refund for a product, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.product.productRevenue | INTEGER | The revenue of the product, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.product.productSKU | STRING | Product SKU. |
| hits.product.productVariant | STRING | Product Variant. |
| hits.product.v2ProductCategory | STRING | Product Category. |
| hits.product.v2ProductName | STRING | Product Name. |
| hits.promotion | RECORD | This row and nested fields are populated for each hit that contains Enhanced Ecommerce PROMOTION information. |
| hits.promotion.promoCreative | STRING | The text or creative variation associated with the promotion. |
| hits.promotion.promoId | STRING | Promotion ID. |
| hits.promotion.promoName | STRING | Promotion Name. |
| hits.promotion.promoPosition | STRING | Promotion position on site. |
| hits.promotionActionInfo | RECORD | This row and nested fields are populated for each hit that contains Enhanced Ecommerce PROMOTION action information. |
| hits.promotionActionInfo.promoIsView | BOOLEAN | True if the Enhanced Ecommerce action is a promo view. |
| hits.promotionActionInfo.promoIsClick | BOOLEAN | True if the Enhanced Ecommerce action is a promo click. |
| hits.page.searchCategory | STRING | If this was a search-results page, this is the category selected. |
| hits.transaction | RECORD | This section is populated for each hit with type = "TRANSACTION". |
| hits.transaction.transactionId | STRING | The transaction ID of the ecommerce transaction. |
| hits.transaction.transactionRevenue | INTEGER | Total transaction revenue, expressed as the value passed to Analytics multiplied by 10^6. (e.g., 2.40 would be given as 2400000). |
| hits.transaction.transactionTax | INTEGER | Total transaction tax, expressed as the value passed to Analytics multiplied by 10^6. (e.g., 2.40 would be given as 2400000). |
| hits.transaction.transactionShipping | INTEGER | Total transaction shipping cost, expressed as the value passed to Analytics multiplied by 10^6. (e.g., 2.40 would be given as 2400000). |
| hits.transaction.affiliation | STRING | The affiliate information passed to the ecommerce tracking code. |
| hits.transaction.currencyCode | STRING | The local currency code for the transaction. |
| hits.transaction.localTransactionRevenue | INTEGER | Total transaction revenue in local currency, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.transaction.localTransactionTax | INTEGER | Total transaction tax in local currency, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.transaction.localTransactionShipping | INTEGER | Total transaction shipping cost in local currency, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.item | RECORD | This section will be populated for each hit with type = "ITEM". |
| hits.item.transactionId | STRING | The transaction ID of the ecommerce transaction. |
| hits.item.productName | STRING | The name of the product. |
| hits.item.productCategory | STRING | The category of the product. |
| hits.item.productSku | STRING | The SKU or product ID. |
| hits.item.itemQuantity | INTEGER | The quantity of the product sold. |
| hits.item.itemRevenue | INTEGER | Total revenue from the item, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.item.currencyCode | STRING | The local currency code for the transaction. |
| hits.item.localItemRevenue | INTEGER | Total revenue from this item in local currency, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000). |
| hits.contentGroup | RECORD | This section contains information about content grouping. Learn more |
| hits.contentGroup.contentGroupX | STRING | The content group on a property. A content group is a collection of content that provides a logical structure that can be determined by tracking-code or page-title/URL regex match, or predefined rules. (Index X can range from 1 to 5.) |
| hits.contentGroup.previousContentGroupX | STRING | Content group that was visited before another content group. (Index X can range from 1 to 5.) |
| hits.contentGroup.contentGroupUniqueViewsX | STRING | The number of unique content group views. Content group views in different sessions are counted as unique content group views. Both the pagePath and pageTitle are used to determine content group view uniqueness. (Index X can range from 1 to 5.) |
| hits.contentInfo | RECORD | This section will be populated for each hit with type = "APPVIEW". |
| hits.contentInfo.contentDescription | STRING | The description of the content being viewed as passed to the SDK. |
| hits.appInfo | RECORD | This section will be populated for each hit with type = "APPVIEW" or "EXCEPTION". |
| hits.appInfo.appInstallerId | STRING | ID of the installer (e.g., Google Play Store) from which the app was downloaded. |
| hits.appInfo.appName | STRING | The name of the application. |
| hits.appInfo.appVersion | STRING | The version of the application. |
| hits.appInfo.appId | STRING | The ID of the application. |
| hits.appInfo.screenName | STRING | The name of the screen. |
| hits.appInfo.landingScreenName | STRING | The landing screen of the session. |
| hits.appInfo.exitScreenName | STRING | The exit screen of the session. |
| hits.appInfo.screenDepth | STRING | The number of screenviews per session reported as a string. Can be useful for historgrams. |
| hits.exceptionInfo | RECORD | This section is populated for each hit with type = "EXCEPTION". |
| hits.exceptionInfo.description | STRING | The exception description. |
| hits.exceptionInfo.isFatal | BOOLEAN | If the exception was fatal, this is set to true. |
| hits.eventInfo | RECORD | This section is populated for each hit with type = "EVENT". |
| hits.eventInfo.eventCategory | STRING | The event category. |
| hits.eventInfo.eventAction | STRING | The event action. |
| hits.eventInfo.eventLabel | STRING | The event label. |
| hits.eventInfo.eventValue | INTEGER | The event value. |
| hits.customVariables | RECORD | This section contains any hit-level custom variables. This is a repeated field and has an entry for each variable that is set. |
| hits.customVariables.index | INTEGER | The index of the custom variable. |
| hits.customVariables.customVarName | STRING | The custom variable name. |
| hits.customVariables.customVarValue | STRING | The custom variable value. |
| hits.customDimensions | RECORD | This section contains any hit-level custom dimensions. This is a repeated field and has an entry for each dimension that is set. |
| hits.customDimensions.index | INTEGER | The index of the custom dimension. |
| hits.customDimensions.value | STRING | The value of the custom dimension. |
| hits.customMetrics | RECORD | This section contains any hit-level custom metrics. This is a repeated field and has an entry for each metric that is set. |
| hits.customMetrics.index | INTEGER | The index of the custom metric. |
| hits.customMetrics.value | INTEGER | The value of the custom metric. |
| privacy_info.ads_storage | STRING | Whether ad targeting is enabled for a user.<br>Possible values: TRUE, FALSE, UNKNOWN |
| privacy_info.analytics_storage | STRING | Whether Analytics storage is enabled for the user.<br>Possible values: TRUE, FALSE, UNKNOWN |
| privacy_info.uses_transient_token | STRING | Whether a web user has denied Analytics storage and the developer has enabled measurement without cookies based on transient tokens in server data.<br>Possible values: TRUE, FALSE, UNKNOWN |