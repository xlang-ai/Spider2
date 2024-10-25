#### Food Events Cleansing

1. **`report_number`**: A unique identifier for each reported food event.



2. **`reactions`**: A list of reactions associated with the food event.

   \- Transformed using `SPLIT(reactions, ',')`.



3. **`outcomes`**: A list of outcomes associated with the food event.

   \- Transformed using `SPLIT(outcomes, ',')`.



4. **`products`**: A struct containing detailed information about the product involved in the event.

   \- **`brand_name`**: List of brand names of the products.

​     \- Transformed using a CASE statement to handle digits before commas, replacing `,` with `--`.

   \- **`industry_code`**: List of industry codes.

​     \- Transformed using `SPLIT(REPLACE(products_industry_code, ', ', ' -- '))`.

   \- **`role`**: List of roles associated with the product.

​     \- Transformed using `SPLIT(REPLACE(products_role, ', ', ' -- '))`.

   \- **`industry_name`**: List of industry names.

​     \- Transformed using `SPLIT(REPLACE(products_industry_name, ', ', ' -- '))`.



5. **`date_created`**: The date the event was created in the system.



6. **`date_started`**: The date when the adverse event started.



7. **`consumer_gender`**: Gender of the consumer involved in the event.



8. **`consumer_age`**: Age of the consumer involved in the event.



9. **`consumer_age_unit`**: Unit for the consumer's age (e.g., year, month).



10. **`industry_code_length`**: The number of industry codes associated with the product.

​    \- Calculated using `ARRAY_LENGTH(SPLIT(REPLACE(products_industry_code, ', ', ' -- ')))`.



11. **`brand_name_length`**: The number of brand names associated with the product.

​    \- Calculated using `ARRAY_LENGTH` with a nested `CASE` statement for preprocessing.



### Data Cleansing Logic



\- **Handling Brand Names with Digits**: A regular expression is used to check for digits followed by commas in the `products_brand_name` field. If such a pattern is detected, the brand name string is split into appropriately formatted elements.



\- **Replacement of Delimiters**: Commas followed by a space in multi-valued fields are replaced with `--` to ensure consistent splitting of the string into an array.



### Data Output



The result of this SQL script is a cleansed dataset (`food_events_cleansed`) with enhanced structure, particularly in string fields that originally held multiple values separated by delimiters. Upon execution, you can query this intermediate table to gain insights into specific food event attributes.



The final SELECT statement retrieves all columns from the `food_events_cleansed` subquery, enabling further analysis or data exportation tasks.



\## Conclusion



This data cleansing process is designed to ensure the consistency and usability of the FDA Food Events dataset. For any further analysis, you can utilize this processed data to implement more complex queries or insights.