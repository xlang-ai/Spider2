# Subplot Size and Macroplot Size Calculation Methods

## Overview

In forest inventory analysis, different types of plots are used to estimate forest characteristics. Two commonly used plot sizes are **subplot** and **macroplot**, each serving a distinct purpose for data collection at different scales.

This document provides a detailed explanation of the **subplot size** and **macroplot size** calculation methods using mathematical formulas.

## Subplot Size Calculation

### Definition
A **subplot** is a smaller area within a larger plot, often used to collect more detailed forest data. Subplots are utilized when fine-grained measurements are needed for specific forest conditions.

### Calculation Formula
The size of a subplot is calculated as follows:

\[
\text{Subplot Area} = 
\begin{cases} 
E \times P \times A_s, & \text{if proportion basis} = \text{'SUBP'} \text{ and } A_s > 0 \\
0, & \text{otherwise}
\end{cases}
\]

### Explanation of Terms:
- **E** (Expansion Factor): A multiplier used to adjust the size of the subplot to account for its proportion within a larger area.
- **P** (Condition Proportion Unadjusted): Represents the unadjusted proportion of the forest condition within the subplot.
- **A_s** (Adjustment Factor for Subplot): A factor applied to adjust the subplot size based on specific conditions or measurements.

### Interpretation:
If the **proportion basis** is `'SUBP'` and the **adjustment factor for the subplot** \( A_s \) is greater than 0, the subplot size is calculated by multiplying the **expansion factor** \( E \), **condition proportion** \( P \), and the **adjustment factor** \( A_s \):

\[
\text{Subplot Area} = E \times P \times A_s
\]

If these conditions are not met, the subplot size is set to 0.

## Macroplot Size Calculation

### Definition
A **macroplot** is a larger area within a forest inventory used for broader data collection. Macroplots cover more extensive areas compared to subplots and are used to estimate forest characteristics applicable to large sections of the forest.

### Calculation Formula
The size of a macroplot is calculated as follows:

\[
\text{Macroplot Area} = 
\begin{cases} 
E \times P \times A_m, & \text{if proportion basis} = \text{'MACR'} \text{ and } A_m > 0 \\
0, & \text{otherwise}
\end{cases}
\]

### Explanation of Terms:
- **E** (Expansion Factor): A factor that adjusts the macroplot size to reflect its relative size within the larger forest area.
- **P** (Condition Proportion Unadjusted): The unadjusted proportion of the forest condition within the macroplot.
- **A_m** (Adjustment Factor for Macroplot): A factor used to adjust the macroplot size based on specific forest conditions or measurements.

### Interpretation:
If the **proportion basis** is `'MACR'` and the **adjustment factor for the macroplot** \( A_m \) is greater than 0, the macroplot size is calculated using the following formula:

\[
\text{Macroplot Area} = E \times P \times A_m
\]

If these conditions are not met, the macroplot size is set to 0.

## Summary of Key Differences

| Parameter                     | Subplot Size Calculation                   | Macroplot Size Calculation                  |
|--------------------------------|--------------------------------------------|---------------------------------------------|
| **Proportion Basis**           | `'SUBP'`                                   | `'MACR'`                                    |
| **Adjustment Factor Applied**  | Adjustment Factor for Subplot \( A_s \)     | Adjustment Factor for Macroplot \( A_m \)   |
| **Applicability**              | Used for fine-grained data collection       | Used for broader, large-scale data collection |

### Common Calculation Components:
Both **subplot** and **macroplot** calculations use:
- **E** (Expansion Factor): Reflects how much area the plot represents in the larger forest.
- **P** (Condition Proportion Unadjusted): The proportion of the forest condition applicable to the plot.

These components are scaled based on whether the condition applies to a subplot or macroplot.
