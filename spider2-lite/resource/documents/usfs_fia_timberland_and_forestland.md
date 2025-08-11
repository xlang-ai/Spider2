# USFS FIA Timberland And Forestland

### Timberland Acres Data Model Detailed Description

**Timberland Acres** data model is crafted to analyze and evaluate forest plots based on several criteria and calculations that reflect the current status and productivity of timberlands.

#### Attributes and Calculations:
- **plot_sequence_number**: Unique identifier for each plot, used to distinguish individual plots within datasets.
- **evaluation_type**: Type of the evaluation performed, specifically `EXPCURR` for current evaluations, ensuring the analysis reflects the most recent data.
- **evaluation_group**: The grouping classification for evaluations, used to organize data based on evaluation cycles or other relevant grouping metrics.
- **evaluation_description**: Descriptive text providing details about the purpose and scope of each evaluation.
- **plot_state_code_name** (`state_name`): The name of the state where the plot is located, facilitating regional analysis and reporting.
- **inventory_year**: The year in which the inventory or data collection was conducted.
- **state_code**: Numerical or textual code representing the state, used for filtering and aggregation in analysis.

#### Conditional Calculations for Area:
- **macroplot_acres**: Calculated for plots where the proportion basis is 'MACR' and the adjustment factor for the macroplot is greater than zero. The formula used is:
  \[
  p.\text{expansion\_factor} \times c.\text{condition\_proportion\_unadjusted} \times p.\text{adjustment\_factor\_for\_the\_macroplot}
  \]
- **subplot_acres**: Calculated for plots where the proportion basis is 'SUBP' and the subplot adjustment factor is greater than zero, using the formula:
  \[
  p.\text{expansion\_factor} \times c.\text{condition\_proportion\_unadjusted} \times p.\text{adjustment\_factor\_for\_the\_subplot}
  \]

#### Filter Conditions:
- **condition_status_code**: Set to 1, including only active conditions.
- **reserved_status_code**: Set to 0, excluding reserved plots from the analysis.
- **site_productivity_class_code**: Limited to values 1 through 6, representing different levels of site productivity.


### Forestland Acres Data Model Detailed Description

**Forestland Acres** data model is designed to analyze and evaluate forest plots comprehensively, focusing on the attributes and conditions that affect forest management and conservation efforts.

#### Attributes and Calculations:
- **plot_sequence_number**: A unique identifier assigned to each plot for tracking and differentiation within various analyses.
- **evaluation_type**: Specifies the type of evaluation, specifically focusing on 'EXPCURR' (current evaluations), to ensure that the analyses reflect the most recent assessments of forest conditions.
- **evaluation_group**: Classification for grouping plot data based on the timing or other criteria of evaluations. This helps in organizing the data into manageable and comparable segments.
- **evaluation_description**: Provides detailed explanations regarding the evaluation purpose and methodology, offering insights into what each evaluation aims to achieve.
- **plot_state_code_name** (`state_name`): Indicates the state where the plot is located, which is crucial for regional analysis and resource management.
- **inventory_year**: Marks the year when the data was collected, crucial for temporal analysis and understanding changes over time.
- **state_code**: Serves as a geographical identifier, enabling state-wise aggregation and analysis.

#### Conditional Calculations for Area:
- **macroplot_acres**: The area calculated for plots classified under the 'MACR' proportion basis when the macroplot adjustment factor is greater than zero, using the formula:
  \[
  p.\text{expansion\_factor} \times c.\text{condition\_proportion\_unadjusted} \times p.\text{adjustment\_factor\_for\_the\_macroplot}
  \]
- **subplot_acres**: Similar to macroplot acres, these are calculated for plots under the 'SUBP' proportion basis when the subplot adjustment factor is greater than zero:
  \[
  p.\text{expansion\_factor} \times c.\text{condition\_proportion\_unadjusted} \times p.\text{adjustment\_factor\_for\_the\_subplot}
  \]

#### Filter Conditions:
- **condition_status_code**: Set to 1, ensuring that only plots that are currently active are considered in the analysis. This is critical for maintaining the relevancy and accuracy of the evaluation.
- Unlike Timberland Acres, the Forestland Acres model does not specifically filter by **reserved_status_code** or **site_productivity_class_code**. This allows for a broader analysis scope, inclusive of all forest plots under current evaluation regardless of their reserved status or productivity class.
