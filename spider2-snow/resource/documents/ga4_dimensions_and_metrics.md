# Channel Group

| Channel                | Description                                                                                                                                                                |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Affiliates             | Affiliates is the channel by which users arrive at your site/app via links on affiliate sites.                                                                              |
| Audio                  | Audio is the channel by which users arrive at your site/app via ads on audio platforms (e.g., podcast platforms).                                                           |
| Cross-network          | Cross-network is the channel by which users arrive at your site/app via ads that appear on a variety of networks (e.g., Search and Display).                                 |
| Direct                 | Direct is the channel by which users arrive at your site/app via a saved link or by entering your URL.                                                                      |
| Display                | Display is the channel by which users arrive at your site/app via display ads, including ads on the Google Display Network.                                                 |
| Email                  | Email is the channel by which users arrive at your site/app via links in email.                                                                                             |
| Mobile Push Notifications | Mobile Push Notifications is the channel by which users arrive at your site/app via links in mobile-device messages when they're not actively using the app.                 |
| Organic Search         | Organic Search is the channel by which users arrive at your site/app via non-ad links in organic-search results.                                                            |
| Organic Shopping       | Organic Shopping is the channel by which users arrive at your site/app via non-ad links on shopping sites like Amazon or eBay.                                              |
| Organic Social         | Organic Social is the channel by which users arrive at your site/app via non-ad links on social sites like Facebook or Twitter.                                             |
| Organic Video          | Organic Video is the channel by which users arrive at your site/app via non-ad links on video sites like YouTube, TikTok, or Vimeo.                                         |
| Paid Search            | Paid Search is the channel by which users arrive at your site/app via ads on search-engine sites like Bing, Baidu, or Google.                                               |
| Paid Shopping          | Paid Shopping is the channel by which users arrive at your site/app via paid ads on shopping sites like Amazon or eBay or on individual retailer sites.                     |
| Paid Social            | Paid Social is the channel by which users arrive at your site/app via ads on social sites like Facebook and Twitter.                                                        |
| Paid Video             | Paid Video is the channel by which users arrive at your site/app via ads on video sites like TikTok, Vimeo, and YouTube.                                                   |
| Referral               | Referral is the channel by which users arrive at your site via non-ad links on other sites/apps (e.g., blogs, news sites).                                                  |
| SMS                    | SMS is the channel by which users arrive at your site/app via links from text messages.                                                                                     |
| Unassigned            | Others                        |



| Channel                   | Conditions                                                                                                                                                                         |
|---------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Direct**                | Source exactly matches "(direct)"<br>AND<br>Medium is one of ("(not set)", "(none)")                                                                                                |
| **Cross-network**         | Campaign Name contains "cross-network"<br>Cross-network includes Demand Gen, Performance Max and Smart Shopping.                                                                   |
| **Paid Shopping**         | Source matches a list of shopping sites (alibaba, amazon, google shopping, shopify, etsy, ebay, stripe, walmart)<br>OR<br>Campaign Name matches regex `^(.*(([^a-df-z]\|^)shop\|shopping).*)$`<br>AND<br>Medium matches regex `^(.*cp.*\|ppc\|retargeting\|paid.*)$` |
| **Paid Search**           | Source matches a list of search sites (baidu,bing,duckduckgo,ecosia,google,yahoo,yandex)<br>AND<br>Medium matches regex `^(.*cp.*\|ppc\|paid.*)$`|
| **Paid Social**           | Source matches a regex list of social sites (badoo,facebook,fb,instagram,linkedin,pinterest,tiktok,twitter,whatsapp)<br>AND<br>Medium matches regex `^(.*cp.*\|ppc\|retargeting\|paid.*)$`                                                                     |
| **Paid Video**            | Source matches a list of video sites (dailymotion,disneyplus,netflix,youtube,vimeo,twitch,vimeo,youtube)<br>AND<br>Medium matches regex `^(.*cp.*\|ppc\|retargeting\|paid.*)$`                                                                            |
| **Display**               | Medium is one of (“display”, “banner”, “expandable”, “interstitial”, “cpm”)                                                                                                        |
| **Organic Shopping**      | Source matches a list of shopping sites (alibaba,amazon,google shopping,shopify,etsy,ebay,stripe,walmart)<br>OR<br>Campaign name matches regex `^(.*(([^a-df-z]\|^)shop\|shopping).*)$`                                                                 |
| **Organic Social**        | Source matches a regex list of social sites (badoo,facebook,fb,instagram,linkedin,pinterest,tiktok,twitter,whatsapp)<br>OR<br>Medium is one of (“social”, “social-network”, “social-media”, “sm”, “social network”, “social media”)                          |
| **Organic Video**         | Source matches a list of video sites (dailymotion,disneyplus,netflix,youtube,vimeo,twitch,vimeo,youtube)<br>OR<br>Medium matches regex `^(.*video.*)$`                                                                                                  |
| **Organic Search**        | Source matches a list of search sites (baidu,bing,duckduckgo,ecosia,google,yahoo,yandex)<br>OR<br>Medium exactly matches organic                                                                                 |
| **Referral**              | Medium exactly matches Referral                                                                                                    |
| **Email**                 | Source = email\|e-mail\|e_mail\|e mail<br>OR<br>Medium = email\|e-mail\|e_mail\|e mail                                                                                              |
| **Affiliates**            | Medium = affiliate                                                                                                                                                                 |
| **Audio**                 | Medium exactly matches audio                                                                                                                                                       |
| **SMS**                   | Source exactly matches sms<br>OR<br>Medium exactly matches sms                                                                                                                      |
| **Mobile Push Notifications** | Medium ends with "push"<br>OR<br>Medium contains "mobile" or "notification"                                                          |
| **Unassigned** | Others                                     |

