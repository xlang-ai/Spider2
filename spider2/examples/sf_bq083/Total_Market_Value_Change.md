## Total Market Value Change

1. **`USD(...)`:**

   \- **Purpose:** This is a user-defined function that formats a floating-point number as a USD currency string.

   \- **Effect:** It wraps the entire sum calculation to produce a string formatted as currency for display purposes.



2. **`SUM(...)`:**

   \- **Purpose:** Aggregates the calculated values for each transaction to provide a total market value change per day.

   

3. **`IFMINT(input, 1, -1)`:**

   \- **Function:** This temporary function checks if the transaction input indicates a mint operation (by checking if it starts with `0x40c10f19`).

   \- **Return Value:** Returns `1` for mint operations and `-1` for non-mint operations (such as burn), effectively applying a positive or negative sign to the calculated value.

   

4. **`CAST(CONCAT("0x", LTRIM(SUBSTRING(input, IFMINT(input, 75, 11), 64), "0")) AS FLOAT64)`:**

   \- **Process:**

​     \- **`SUBSTRING(input, IFMINT(input, 75, 11), 64)`:** Extracts a portion of the transaction input string based on the operation type. It uses `75` for mint operations and `11` for non-mint operations (e.g., burn).

​     \- **`LTRIM(...,"0")`:** Removes leading zeros from the extracted substring.

​     \- **`CONCAT("0x", ...)`:** Prepends "0x" to the adjusted string segment, creating a complete hexadecimal string.

​     \- **`CAST(... AS FLOAT64)`:** Converts the hexadecimal string to a floating-point number, interpreting it as a value in the smallest token unit.

​     

5. **`/ 1000000`:**

   \- **Purpose:** Scales down the number from the smallest token unit to a standard unit (e.g., from wei to ether), assuming USDC has six decimal places.



6. **Alias `AS `Δ Total Market Value``:**

   \- **Result:** Names the final output column as "Δ Total Market Value" to clarify the calculation purpose—representing the net change in total market value due to mint and burn operations on that specific day.