# Introduction to the RFM Model

The RFM (Recency, Frequency, Monetary) model segments and scores customers based on three key dimensions:

Recency: The time since the customer's last purchase. Customers who made a purchase more recently are more likely to buy again.

Frequency: The number of purchases made by the customer within a given period. Customers with higher purchase frequency are generally more valuable.

Monetary: The total amount of money spent by the customer. Customers who spend more are typically considered more valuable.

Using these three dimensions, the SQL assigns each customer a score based on their historical order data and classifies them into different customer segments (RFM Buckets).

By taking the values for each customer, bucketing them to produce a score from 1 (lowest) to 5 (highest) and then concatenating all three scores together you get an easy way to divide-up your customers into segments (or “RFM cells”; high-spending new purchasers (514, 5 for recency, 1 for frequency and 4 for monetary value), almost-lost but previously loyal customers (153, 1 for recency, 5 for frequency and 3 for monetary value) and so on.

One of the most popular ways to visualize your customer RFM segments is by using a grid such as the one below, with each segment labelled and sized proportionate to the volume of customers each contains.

# RFM Segmentation Calculation


RFM analysis is particularly useful for sales and customer teams needing to focus their limited time and money on those customers for whom a change in behavior — from lapsed to active, or first-time to repeat shopper for example — would have the most impact on your bottom line.

For example, by focusing retention efforts on customers who used to be frequent, loyal and high-value purchasers (RFM segment 355) the revenue upside is obviously much greater than if they managed to retain customers who were previously infrequent low-value purchasers (RFM segment 132).

Similarly, there’s little point in incentivising customers who are already your most loyal, frequent and high-spending customers (RFM segment 555) when spending those incentives on customers who’ve just made their first purchase and have the potential to also become loyal and valuable repeat customers (RFM segment 514, for example)

Building an RFM model is often one of the first projects our clients’ data teams ask us to help deliver as the concept is straightforward, the data required has usually just been centralized and the output is immediately actionable by customer and marketing teams keen to focus their time on customer activity that has the greatest potential to retain or increase revenue.

We’ve created an RFM model using the project timesheets and invoicing data we centralise in our Google BigQuery data warehouse and used it to create the RFM analysis dashboard shown in the screenshot at the start of this blog; in the rest of this blog I’ll walk through how we build the model using dbt and LookML and used the visualization features in Looker to help analyze and make the data actionable.

For the purposes of the RFM model we created for our consulting business, we defined our Recency, Frequency and Monetary Value measures as:

Recency: the number of months since the last invoice raised for a customer

Frequency : the number of invoices raised for the customer in the 12 months leading-up to their last invoice

Monetary Value : the total value of invoices raised for the customer over the 12 months leading-up to their last invoice

The RFM (Recency, Frequency, Monetary) model categorizes customers based on three dimensions: **Recency**, **Frequency**, and **Monetary**. This helps in identifying high-value customers, those at risk of leaving, and others who require attention. Below is a detailed explanation of how customers are grouped based on these three factors.


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
