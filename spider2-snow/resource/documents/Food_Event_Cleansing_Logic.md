#### Food Events Cleansing

1. **`report_number`**: A unique identifier for each reported food event.



2. **`reactions`**: A list of reactions associated with the food event.

   \- Each reaction is separated into individual entries from a comma-delimited string to facilitate easier analysis and access.



3. **`outcomes`**: A list of outcomes associated with the food event.

   \- Outcomes are individually listed by breaking down the comma-separated values into distinct elements for clear interpretation and usage.


4. **`products_brand_name`**: A list of product brand names, modified to address patterns where numeric sequences followed by commas could disrupt list separation.
   - Commas followed by a space within these patterns are replaced with double hyphens (` -- `) to ensure accurate parsing and to maintain the integrity of brand names.

5. **`products_industry_code`**: List of industry codes.
   - Commas followed by a space, which typically separate these codes, are replaced with double hyphens (` -- `) to ensure each code is distinctly recognized.

6. **`products_industry_role`**: List of roles associated with the product.
   - To ensure clear delineation, commas followed by a space that typically separate these roles are replaced with double hyphens (` -- `).

7. **`products_industry_name`**: List of industry names.
   - Commas followed by a space, which typically separate these names, are replaced with double hyphens (` -- `) to prevent any misinterpretation of industry names.




8. **`date_created`**: The date the event was created in the system.



9. **`date_started`**: The date when the adverse event started.



10. **`consumer_gender`**: Gender of the consumer involved in the event.



11. **`consumer_age`**: Age of the consumer involved in the event.



12. **`consumer_age_unit`**: Unit for the consumer's age (e.g., year, month).



13. **`industry_code_length`**: Represents the total number of distinct industry codes associated with the product.
    - The count is derived by transforming the `products_industry_code` field. Commas followed by a space are replaced with double hyphens (` -- `) to ensure that composite codes are not incorrectly split. The total number of industry codes is then determined by measuring the length of the resulting array.

14. **`brand_name_length`**: Reflects the number of unique brand names listed for the product.
    - This value is computed by first modifying the `products_brand_name` to accommodate special formats, such as numeric sequences that may include commas followed by a space. These commas are replaced with double hyphens (` -- `) to ensure proper parsing. The total count of brand names is obtained by calculating the length of the array after this transformation.
