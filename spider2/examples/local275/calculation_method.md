
# Explanation of Metrics

## 1. Sales-to-CMA Ratio
- **Definition**: This ratio compares actual sales to the centered moving average (CMA) of sales.
- **Calculation**:
  - **Centered Moving Average (CMA)**: The CMA is a smoothed value of sales calculated over a rolling 12-month period. It averages sales from the months before and after a given month, specifically using two overlapping windows (5 months before and 6 months after, and vice versa).
  - **Sales-to-CMA Ratio**: The ratio is computed by dividing the actual sales amount for a month by its corresponding CMA value. A ratio greater than 2 indicates that the actual sales are more than twice the smoothed average for that period, suggesting significantly higher-than-average sales.

## 2. 12-Month Overlapping Windows
- **Definition**: A method to smooth sales data over time by averaging values in a specified window.
- **Calculation**:
  - **Window Size**: The window spans 12 months, with the specific approach involving overlapping periods. 
  - **First Window**: For a given month, this window includes 5 months before and 6 months after.
  - **Second Window**: Another window includes 6 months before and 5 months after the given month.
  - **Averaging**: Sales data is averaged over these two overlapping windows to compute the CMA. This method smooths out fluctuations by considering both the past and future sales in the calculation.

## 3. Restriction to the 7th and 30th Months
- **Definition**: A filter applied to focus calculations within a specific range of months.
- **Calculation**:
  - **Time Range**: Only the months between the 7th and 30th time steps (which correspond to specific periods) are considered for calculating the CMA and ratio.
  - **Purpose**: This restriction is used to avoid edge effects in the data where the moving average might be less reliable (e.g., at the very beginning or end of the available data). By focusing on these months, the calculations are more stable and meaningful.
