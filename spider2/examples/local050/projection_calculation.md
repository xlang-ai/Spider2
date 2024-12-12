## Projection Calculation Method

### Steps for Projection Calculation

1. **Aggregate Historical Sales Data**

   - **Data Collection**: Gather sales data for products sold in France, including sales amounts each month for the years 2019, 2020, and 2021.
   - **Summarize Sales**: Sum up the sales amounts for each product, country, month, and year.

2. **Calculate Average Sales**

   - **Monthly Averages**: Compute the average sales amount for each product and month across all available months to establish a baseline of typical sales.

3. **Project Sales for 2021**

   - **Identify Changes**: Determine how sales changed from 2019 to 2020 for each product and month. Calculate the percentage change in sales from 2019 to 2020.
   - **Apply Changes**: Use this percentage change to estimate the sales for each month in 2021.

   **Projection Formula**:
   - For 2021:
     - Calculate the difference in sales between 2020 and 2019.
     - Compute the percentage change relative to 2019 sales.
     - Apply this percentage change to the 2020 sales to estimate 2021 sales.
     - The formula used in the SQL query is:

       ```plaintext
       (((Sales in 2020 - Sales in 2019) / Sales in 2019) * Sales in 2020) + Sales in 2020
       ```

     - This formula calculates the projected sales for 2021 based on the observed trend from 2019 to 2020.

   - For other years (not 2021):
     - Use the average sales value calculated for each month.

4. **Adjust for Currency Conversion**

   - **Conversion Rates**: Convert the projected sales figures into USD using monthly conversion rates.
   - **Currency Adjustment**: Multiply the projected sales figures by the conversion rates to adjust to USD. If specific rates are not available, use a default rate of 1.

5. **Calculate Monthly Averages in USD**

   - **Monthly Projections**: Compute the average projected sales for each month in 2021, adjusting for currency conversion. Round the results to two decimal places.

6. **Compile Results**

   - **Organize Data**: Arrange the projected sales figures in a report, showing the estimated sales for each month in USD.

### Summary

The projection calculation involves analyzing historical sales data from 2019 and 2020 to determine trends, applying these trends to estimate sales for 2021, and adjusting for currency differences. The result is a forecast of monthly sales in USD for 2021.
