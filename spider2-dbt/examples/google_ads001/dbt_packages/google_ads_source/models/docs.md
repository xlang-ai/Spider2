{% docs _fivetran_id %}
Unique ID used by Fivetran to sync and dedupe data.
{% enddocs %}

{% docs _fivetran_synced %}
Timestamp of when a record was last synced.
{% enddocs %}

{% docs account_descriptive_name %}
The descriptive name of the Customer account.
{% enddocs %}

{% docs ad_group_id %}
The ID of the AdGroup.
{% enddocs %}

{% docs ad_group_name %}
The name of the AdGroup.
{% enddocs %}

{% docs ad_group_status %}
Status of the ad group.
{% enddocs %}

{% docs campaign_id %}
The ID of the Campaign.
{% enddocs %}

{% docs ad_id %}
The ID of the Ad.
{% enddocs %}

{% docs account_id %}
The ID of the Account.
{% enddocs %}


{% docs ad_status %}
Status of the Ad.
{% enddocs %}

{% docs campaign_name %}
The name of the Campaign.
{% enddocs %}

{% docs campaign_status %}
Status of the Campaign.
{% enddocs %}

{% docs clicks %}
The number of clicks.
{% enddocs %}

{% docs conversions %}
The number of conversions you've received, across your conversion actions. Conversions are measured with conversion tracking and may include [modeled](https://support.google.com/google-ads/answer/10081327?sjid=12862894247631803415-NC) conversions in cases where you are not able to observe all conversions that took place. You can use this column to see how often your ads led customers to actions that you’ve defined as valuable for your business.
{% enddocs %}

{% docs conversions_value %}
The sum of monetary values for your `conversions`. You have to enter a value in the Google Ads UI for your conversion actions to make this metric useful.
{% enddocs %}

{% docs view_through_conversions %}
For video campaigns, view-through conversions tell you when an _impression_ of your video ad leads to a conversion on your site. The last impression of a video ad will get credit for the view-through conversion.

Keep in mind: An impression is different than a “view” of a video ad. A “view” is counted when someone watches 30 seconds (or the whole ad if it’s shorter than 30 seconds) or clicks on a part of the ad. A “view” that leads to a conversion is counted in the `conversions` column.
{% enddocs %}

{% docs cost %}
The sum of your cost-per-click (CPC) and cost-per-thousand impressions (CPM) costs during this period.
{% enddocs %}

{% docs date %}
The date being reported on.
{% enddocs %}

{% docs effective_final_url %}
Effective final URL of the impressions.
{% enddocs %}

{% docs external_customer_id %}
The Customer ID.
{% enddocs %}

{% docs impressions %}
Count of how often your ad has appeared on a search results page or website on the Google Network.
{% enddocs %}

{% docs criteria_id %}
The Criterion ID.
{% enddocs %}

{% docs gcl_id %}
The Google Click ID.
{% enddocs %}

{% docs criteria %}
Descriptive string for the Criterion.
{% enddocs %}

{% docs criteria_destination_url %}
Destination URL of the criterion that triggered ads.
{% enddocs %}

{% docs criteria_type %}
The type of the Criterion.
{% enddocs %}

{% docs base_url %}
The base URL of the ad, extracted from the `final_urls`.
{% enddocs %}

{% docs url_host %}
The URL host of the ad, extracted from the `final_urls`.
{% enddocs %}

{% docs url_path %}
The URL path of the ad, extracted from the `final_urls`.
{% enddocs %}

{% docs utm_source %}
The utm_source parameter of the ad, extracted from the `final_urls`.
{% enddocs %}

{% docs utm_medium %}
The utm_medium parameter of the ad, extracted from the `final_urls`.
{% enddocs %}

{% docs utm_campaign %}
The utm_campaign parameter of the ad, extracted from the `final_urls`.
{% enddocs %}

{% docs utm_content %}
The utm_content parameter of the ad, extracted from the `final_urls`.
{% enddocs %}

{% docs utm_term %}
The utm_term parameter of the ad, extracted from the `final_urls`.
{% enddocs %}

{% docs updated_at %}
Timestamp of when the record was last updated in Google Ads.
{% enddocs %}

{% docs ad_type %}
The type of the ad in Google Ads.
{% enddocs %}

{% docs ad_group_type %}
The type of the ad group in Google Ads.
{% enddocs %}

{% docs is_most_recent_record %}
Boolean representing whether the record is the most recent version of the object.
{% enddocs %}

{% docs ad_network_type %}
The Google Ad network type used across the account.
{% enddocs %}

{% docs device %}
Account ad performance per unique device where the ads were served.
{% enddocs %}

{% docs source_relation %}
The source of the record if the unioning functionality is being used. If not this field will be empty.
{% enddocs %}