### ERCOT Daily Market Dynamics Report: Data Columns Description

This documentation outlines the columns included in the dataset for the ERCOT daily market dynamics report generated for October 1, 2022. Each column represents specific data points critical for assessing market behavior and operational effectiveness.

#### Column Descriptions

- **iso**: The ISO (Independent System Operator) code for ERCOT, indicating the specific grid management entity.

- **datetime**: Records the specific date and time for which the dataset provides data, targeted at October 1, 2022.

- **timezone**: Specifies the local time zone applicable to the datetime values.

- **datetime_utc**: Provides the Coordinated Universal Time (UTC) equivalent of the local datetime.

- **onpeak**: A binary indicator noting whether the reported time falls within peak demand hours.

- **offpeak**: A binary indicator showing whether the time is considered off-peak in terms of energy demand.

- **wepeak**: Indicates whether the datetime falls during weekend peak hours.

- **wdpeak**: Indicates whether the datetime falls during weekday peak hours.

- **marketday**: Signifies the market day that corresponds with the datetime, useful for financial and trading analyses.

- **price_node_name**: The descriptive name of the price node from which energy pricing data is sourced.

- **price_node_id**: The unique identifier for the price node, facilitating precise data querying and aggregation.

- **dalmp**: The Day-Ahead Locational Marginal Price, reflecting the planned price of electricity for the next day.

- **rtlmp**: The Real-Time Locational Marginal Price, indicating the actual price of electricity at the time of generation and consumption.

- **load_zone_name**: The name assigned to the load zone which is the focus of the load and generation data.

- **load_zone_id**: The unique numeric identifier for the load zone concerned.

- **load_forecast**: The forecasted electrical load for the datetime, which predicts the total power demand.

- **load_forecast_publish_date**: The date when the load forecast data was published.

- **rtload**: The actual measured electrical load at the reported datetime, providing insight into real-time demand.

- **wind_gen_forecast**: The forecasted amount of wind-generated power for the datetime.

- **wind_gen_forecast_publish_date**: The publication date of the wind generation forecast data.

- **wind_gen**: The actual measured amount of electricity generated from wind at the reported datetime, aggregated to an hourly basis.

- **solar_gen_forecast**: The forecasted solar power generation for the datetime.

- **solar_gen_forecast_publish_date**: The date when the solar generation forecast was published.

- **solar_gen**: The actual measured solar energy generation at the datetime, summarized hourly from finer granularity data.

- **net_load_forecast**: Computed as the total forecasted load minus the combined forecasted wind and solar generation, representing the net load expected from non-renewable sources.

- **net_load_real_time**: Calculated as the real-time load minus the sum of actual wind and solar generation, providing a real-time assessment of net load reliance on non-renewable energy sources.

