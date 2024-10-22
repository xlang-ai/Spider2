# Decision Log
## Ads Associated with Multiple Ad Groups
It was discovered within the source data that a single Ad can be associated with multiple ad groups on any given day. Because of this, it was determined that the `is_most_recent_record` logic within the `stg_google_ads__ad_history` model needed to account for the `ad_group_id` as well as the individual `ad_id`. As a result, the most recent record of an ad could possibly contain a unique combination of the `ad_id` and the `ad_group_id`.

This logic was only applied to the `stg_google_ads__ad_history` model as it was discovered this relationship was unique to ads and ad groups. If you experience this relationship among any of the other ad hierarchies, please open and [issue](https://github.com/fivetran/dbt_google_ads_source/issues/new?assignees=&labels=bug%2Ctriage&template=bug-report.yml&title=%5BBug%5D+%3Ctitle%3E) and we can continue the discussion!


## Why don't metrics add up across different grains (Ex. ad level vs campaign level)?
Not all ads are served at the ad level. In other words, there are some ads that are served only at the ad group, campaign, etc. levels. The implications are that since not ads are included in the ad-level report, their associated spend, for example, won't be included at that grain. Therefore your spend totals may differ across the ad grain and another grain. 

This is a reason why we have broken out the ad reporting packages into separate hierarchical end models (Ad, Ad Group, Campaign, and more). Because if we only used ad-level reports, we could be missing data.
