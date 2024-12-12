## Tip Rate Calculation and Categorization

The `tip_rate` for each trip is calculated based on the total trip amount and the tip amount. The formula for calculating the tip rate is as follows:



After calculating the tip rate, the values are categorized into the following ranges:

- `no tip`: if `tip_rate = 0`
- `Less than 5%`: if `tip_rate <= 5`
- `5% to 10%`: if `tip_rate > 5` and `tip_rate <= 10`
- `10% to 15%`: if `tip_rate > 10` and `tip_rate <= 15`
- `15% to 20%`: if `tip_rate > 15` and `tip_rate <= 20`
- `20% to 25%`: if `tip_rate > 20` and `tip_rate <= 25`
- `More than 25%`: if `tip_rate > 25`
