# Introduction to the RFM Model

The RFM (Recency, Frequency, Monetary) model segments and scores customers based on three key dimensions:

• Recency (R): How long it has been since the customer’s last purchase. A lower R score (e.g., R = 1) indicates a very recent purchase, while a higher R score (e.g., R = 5) indicates a longer time since the last purchase.

• Frequency (F): How often the customer purchases within a given time period. A lower F score (e.g., F = 1) signifies that the customer buys very frequently, whereas a higher F score (e.g., F = 5) indicates less frequent purchasing.

• Monetary (M): The total amount of money the customer spends. A lower M score (e.g., M = 1) indicates higher overall spending, while a higher M score (e.g., M = 5) signifies lower spending over the measured period.

Each customer’s R, F, and M scores are determined by their respective percentiles when compared to other customers. By concatenating the three scores, you get an “RFM cell”—for instance, a customer with R=1, F=5, and M=2 would fall into the 152 segment.

# RFM Segmentation Calculation

After scoring customers on Recency, Frequency, and Monetary values, the next step is to group them into segments that require different marketing or sales strategies. Typically:

1. Determine each customer’s recency score (R) from 1 to 5 (1 = very recent purchase, 5 = not recent).  
2. Determine each customer’s frequency score (F) from 1 to 5 (1 = most frequent purchases, 5 = least frequent).  
3. Determine each customer’s monetary score (M) from 1 to 5 (1 = highest spending, 5 = lowest spending).  
4. Concatenate these three scores into an RFM score (e.g., 153, 514).

By analyzing the distribution of RFM scores and placing them into buckets—for example, “Champions,” “Loyal Customers,” “At Risk,” “Lost,” etc.—you can tailor marketing, sales, and retention strategies to maximize the potential of each segment. 

For instance, a “Champion” (R=1, F=1, M=1) is a recent, frequent, and high-spending user who is highly valuable to your business, whereas a “Lost” customer (e.g., R=5, F=5, M=5) may require re-engagement offers or might no longer be cost-effective to target. Different segments can thus be prioritized based on their profitability and likelihood of responding positively to marketing efforts.

## RFM Segmentation Logic

Customers are assigned to specific segments (RFM Buckets) based on a combination of their Recency, Frequency, and Monetary scores. The segmentation logic is as follows:

- **Champions**: Customers who have made a recent purchase, with high frequency and high monetary value. These are considered the most valuable customers.
  - Criteria: Recency = 1 and Frequency + Monetary score between 1 and 4.

- **Can't Lose Them**: Previously frequent and high-spending customers who have not made a recent purchase. These customers are at risk of leaving and need attention.
  - Criteria: Recency = 4 or 5 and Frequency + Monetary score between 1 and 2.

- **Hibernating**: Customers whose last purchase was a while ago, with low to moderate frequency and spending. These customers might have lost interest in the products.
  - Criteria: Recency = 4 or 5 and Frequency + Monetary score between 3 and 6.

- **Lost**: Customers who have not purchased in a long time and have low frequency and monetary value. These customers are likely lost.
  - Criteria: Recency = 4 or 5 and Frequency + Monetary score between 7 and 10.

- **Loyal Customers**: Customers who are frequent buyers with decent spending levels, and they have made a purchase relatively recently. These customers are likely to be very loyal.
  - Criteria: Recency = 2 or 3 and Frequency + Monetary score between 1 and 4.

- **Needs Attention**: Customers whose purchase frequency and spending are moderate. They haven't bought very recently, but they could be incentivized to become more active.
  - Criteria: Recency = 3 and Frequency + Monetary score between 5 and 6.

- **Recent Users**: Customers who made a purchase recently, but their frequency and spending are moderate. These are relatively new or inconsistent buyers.
  - Criteria: Recency = 1 and Frequency + Monetary score between 7 and 8.

- **Potential Loyalists**: Customers who show potential to become loyal customers. They have good frequency and monetary scores, and they have made recent purchases. With the right engagement, they could become loyal customers.
  - Criteria:
    - Recency = 1 and Frequency + Monetary score between 5 and 6.
    - OR Recency = 2 and Frequency + Monetary score between 5 and 8.

- **Price Sensitive**: Customers who have made recent purchases but tend to spend less, indicating they may be more sensitive to price.
  - Criteria: Recency = 1 and Frequency + Monetary score between 9 and 10.

- **Promising**: These customers exhibit high potential with decent frequency and monetary scores, and they could become more valuable over time.
  - Criteria: Recency = 2 and Frequency + Monetary score between 9 and 10.

- **About to Sleep**: Customers whose frequency and spending are low, and their last purchase was some time ago. These customers are likely to become inactive.
  - Criteria: Recency = 3 and Frequency + Monetary score between 7 and 10.

## Summary

This segmentation logic groups customers based on their behavior in terms of when they last purchased (Recency), how often they purchase (Frequency), and how much they spend (Monetary). By understanding which group a customer belongs to, organizations can tailor marketing strategies to engage the right audience more effectively, improving customer retention and maximizing value.
