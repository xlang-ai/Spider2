### Document: Sliding Window Calculation for Weighted Moving Average

#### 1. **Overview**
In the SQL query, the **Weighted Moving Average (WMA)** method is applied to smooth the annual patent filing counts for each CPC technology area and identify the "best year" for each CPC group. This sliding window calculation is used to highlight years with significant patent filing activity by giving more weight to recent years while considering past data.

The goal of this method is to reduce the impact of short-term fluctuations and better capture long-term trends in patent filing activities, particularly in fast-evolving technology areas.

#### 2. **Weighted Moving Average (WMA) Calculation**

##### 2.1 **Definition**
Weighted Moving Average (WMA) is a method where each data point is given a different weight, with more recent data points typically receiving higher weights. This approach is useful for identifying trends over time while minimizing the effect of older data that might not be as relevant.

##### 2.2 **Formula**
The formula for calculating the Weighted Moving Average is as follows:

\[
WMA_t = \alpha \cdot x_t + (1 - \alpha) \cdot WMA_{t-1}
\]

Where:
- \(WMA_t\): The weighted moving average for the current year (t).
- \(x_t\): The patent filing count for the current year.
- \(WMA_{t-1}\): The weighted moving average for the previous year.
- \(\alpha\): The smoothing factor (in this case, 0.1).

##### 2.3 **Explanation**
- **Smoothing Factor (\(\alpha\))**: The smoothing factor determines how much weight is given to the most recent data point. In this case, the smoothing factor is 0.1, meaning 10% of the weight is assigned to the current year's filing count, and the remaining 90% is based on the previous year’s moving average.
- **Sliding Window**: As we move through the years, the weighted average continuously updates using the most recent filing count and the previous year's weighted average. This creates a "sliding window" where each year's filing count is incorporated into the calculation.
