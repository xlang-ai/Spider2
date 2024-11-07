# Push Notification Analysis

## Overview
This document details an SQL query that analyzes user responses to push notifications within the timeframe of 8:00 AM to 9:00 AM on June 1, 2023. It is designed to assess the impact and effectiveness of push notification campaigns across various metrics.

## Data Sources
The analysis utilizes four distinct subqueries pulling from push notification event views:
- **Send Events**
- **Bounce Events**
- **Open Events**
- **Influenced Open Events**

## Query Description
Each subquery counts and categorizes events based on the type of interaction (sent, bounced, opened, influenced open), along with detailed user and device information.

### Send Events
- **Table**: `USERS_MESSAGES_PUSHNOTIFICATION_SEND_VIEW`
- **Columns**: ID, app group ID, user ID, campaign ID, message variation ID, platform, ad tracking enabled, event timestamp

### Bounce Events
- **Table**: `USERS_MESSAGES_PUSHNOTIFICATION_BOUNCE_VIEW`
- **Columns**: Same as Send Events

### Open Events
- **Table**: `USERS_MESSAGES_PUSHNOTIFICATION_OPEN_VIEW`
- **Columns**: Same as Send Events plus carrier, browser, and device model

### Influenced Open Events
- **Table**: `USERS_MESSAGES_PUSHNOTIFICATION_INFLUENCEDOPEN_VIEW`
- **Columns**: Same as Open Events

## Results Aggregation
The final output of the query is grouped by:
- App Group ID
- Campaign ID
- User ID
- Message Variation ID
- Platform
- Ad Tracking Enabled
- Device Information (Carrier, Browser, Device Model)

### Metrics Included
- `push_notification_sends`: Total number of notifications sent.
- `unique_push_notification_sends`: Number of unique users who received notifications.
- `push_notification_bounced`: Total number of notifications that bounced.
- `unique_push_notification_bounced`: Number of unique users who received bounced notifications.
- `push_notification_open`: Total number of notifications opened.
- `unique_push_notification_opened`: Number of unique users who opened notifications.
- `push_notification_influenced_open`: Total number of indirectly opened notifications.
- `unique_push_notification_influenced_open`: Number of unique users who opened notifications indirectly.

## Conclusion
This analysis provides valuable insights into the reach and responsiveness of users to push notifications, helping to guide future marketing strategies and campaign optimizations.
