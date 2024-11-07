The distance between two cities can be calculated using the **Spherical Law of Cosines**. This method estimates the distance based on the geographical coordinates (latitude and longitude) of the cities. Below is a detailed explanation of the calculation process, including the relevant formula.

The distance $d$ between two cities is calculated using the following formula:

$$
d = 6371 \times \arccos \left( \cos(\text{lat}_1) \times \cos(\text{lat}_2) \times \cos(\text{lon}_2 - \text{lon}_1) + \sin(\text{lat}_1) \times \sin(\text{lat}_2) \right)
$$

Where:
- $\text{lat}_1$ and $\text{lat}_2$ are the latitudes of the first and second cities in **radians**.
- $\text{lon}_1$ and $\text{lon}_2$ are the longitudes of the first and second cities in **radians**.
- `6371` is the Earth's average radius in kilometers.
