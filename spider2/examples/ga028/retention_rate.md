How to Calculate User Retention in Big Query from Google Demo Game Analytics Data

As a Product / Website Analyst, I was pretty psyched to discover Google’s public Google Analytics 4 (GA4) gaming event dataset called `firebase-public-project.analytics_153293282.events_*`. The table allows experienced developers and learners alike to experiment with raw GA4 data in Big Query for free. Event data is basically a log of user interactions with your product for analysis .For newbies interested in learning more about event data and GA4, visit my prior blog. This article provides SQL queries for a quick table overview and explains how to utilize Google Big Query to calculate user retention.


What is Retention?
User retention rates are key indicators for whether your product team meets user needs. Improving retention is often central to long term growth strategies.

**Retention measure’s how often and for how long users tend to return to your product.**

The metric can be a powerful proxy for product usefulness and user opinion. Its analysis can reveal critical information like how well your site converts new visitors to users and which items and features are associated with users coming back. If user data is available, retention can also help a business understand the profiles of its most active users (power users). Finally, retention is a great guardrail metric for A/B tests. Successful, product oriented companies prioritize a healthy user bases over short term profits.


**Common Retention Calculation Strategies**

Two common strategies to calculate retention are: 

a) N-Day retention

b) Unbounded Retention.


a) For N-Day retention, analysts calculate how many users with certain characteristics return over successive periods. It is called N days because we define the length of each period. For example, with N=7 day retention, if User A becomes part of our cohort of interest on day 0 and returns to the product day 5 and day 15, they are counted as retained for week 1 (1–7 days) and week 3 (15–21 days) but not week 2 (8–14 days).


b) For Unbounded Retention, a user is counted as retained each week so long as their most recent product contact was after the week. For example, if User A becomes part of the cohort on day 0 and last returned to the site on day 21, they will be counted as retained in week 1 (1–7 days), week 2 (8–14 days), and week 3 (15–21 days) but not week 4 (22–28 days).

By calculating these metrics, companies can evaluate how well their products hold users’ interests. It also them closer to identifying the patterns that generate return users.


