## Trade Capture Report Data List

Below is a detailed description of each extracted field:

### Extracted Data Fields



1. **`tradeID`**:

   \- Represents the unique identifier for each order in the dataset.

   \- **Type**: STRING



2. **`tradeTimestamp` **:

   \- Indicates the maturity date when the trade is due.

   \- **Type**: TIMESTAMP



3. **`algorithm`**:

   \- Deduces the algorithm used for the trade based on the first four characters of the `TargetCompID`:

​     \- 'MOMO' mapped to 'Momentum'

​     \- 'LUCK' mapped to 'Feeling Lucky'

​     \- 'PRED' mapped to 'Prediction'

   \- **Type**: STRING



4. **`symbol`**:

   \- The trading symbol of the financial instrument involved in the trade.

   \- **Type**: STRING



5. **`openPrice` **:

   \- The last price at which the trade was executed, considered as the opening price for analysis purposes.

   \- **Type**: FLOAT



6. **`closePrice` **:

   \- Represents the strike price of the option for the trade, considered here as the closing price for analysis.

   \- **Type**: FLOAT



7. **`tradeDirection`**:

   \- Extracted from a nested array column `Sides` using `UNNEST`. It signifies the direction of the trade:

​     \- Possible values include 'SHORT' or 'LONG'.

   \- **Type**: STRING



8. **`tradeMultiplier`**:

   \- Derived from the trade direction:

​     \- 'SHORT' results in a value of `-1`

​     \- 'LONG' results in a value of `1`

   \- **Type**: INTEGER