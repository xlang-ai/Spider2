### Data Sources:
Part tables of ChEMBL database:
- activity data: patents-public-data.ebi_chembl.activities_29
- compound structures: patents-public-data.ebi_chembl.compound_structures_29 
- compound properties: patents-public-data.ebi_chembl.compound_properties_29 
- publication documents: patents-public-data.ebi_chembl.docs_29 

### UUID Generation:
Activity Pair UUID (mmp_delta_uuid):
Generated using the MD5 hash of the JSON string of the pair's activity IDs:
to_hex(md5(to_json_string(struct(A, B))))
Both A and B can be activity id or canonical_smiles

### Standard Change Classification:
Determines whether the standard value between two molecules has increased, decreased, or stayed the same:
'decrease': If standard_value_1 >(>>) standard_value_2 and measurement relations do not conflict.
'increase': If standard_value_1 <(<<) standard_value_2 and measurement relations do not conflict.
'no-change': If standard_value_1 =(~) standard_value_2 and both standard relations indicate equality.

### How to Got the publication Date
To compute a publication date for each document, we use the following method, which assigns a date based on the document's relative position within its journal and year, ordered by its first page number.

#### 1. Year Calculation

- **Year**: Use the document's publication year as the year in the date.
  - If the document's year is known, use that year.
  - If the year is missing or unavailable, default to **1970**.

#### 2. Month Calculation

- **Grouping**: For all documents within the same **journal** and **year**, group them together.
- **Ordering**: Within each group, order the documents by their `first_page` number (converted to an integer).
- **Percent Rank Computation**:
  - Calculate the **percent rank** of each document in the ordered list.
  - **Percent Rank Formula**:

    $$\text{Percent Rank} = \frac{\text{Rank of Document} - 1}{\text{Total Documents in Group} - 1}$$

    - The rank starts at 1 for the first document.
    - The percent rank ranges from 0 to 1.
- **Month Assignment**:
  - Scale the percent rank to months by multiplying it by 11:

    $$\text{Scaled Value} = \text{Percent Rank} \times 11$$

  - Take the integer part of the scaled value (floor it):

    $$\text{Floor Value} = \left\lfloor \text{Scaled Value} \right\rfloor$$

  - Add 1 to get the month number (since months are from 1 to 12):

    $$\text{Month} = \text{Floor Value} + 1$$

  - **Note**: If the computed month is not available (e.g., due to missing data), default the month to **1**.

#### 3. Day Calculation

- **Using the Same Percent Rank**: Use the percent rank computed in the month calculation.
- **Day Assignment**:
  - Scale the percent rank to days by multiplying it by **308**:

    $$\text{Scaled Value} = \text{Percent Rank} \times 308$$

    - The number 308 is chosen because it is the product of 11 months and 28 days (11 × 28), representing the total number of days in an 11-month period with 28 days per month.
  - Take the integer part of the scaled value (floor it):

    $$\text{Floor Value} = \left\lfloor \text{Scaled Value} \right\rfloor$$

  - Compute the modulus of the floor value with 28:

    $$\text{Modulo Value} = \text{Floor Value} \bmod 28$$

  - Add 1 to get the day number (since days are from 1 to 28):

    $$\text{Day} = \text{Modulo Value} + 1$$

  - **Note**: If the computed day is not available, default the day to **1**.

### 4. Constructing the publication Date

- Combine the computed **Year**, **Month**, and **Day** to form the publication date.

  $$\text{publication Date} : \text{Year}-\text{Month}-\text{Day}$$

  For example, 2002-06-15.
