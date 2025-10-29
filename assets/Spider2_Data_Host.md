# Host Spider 2.0 Data on Your Snowflake Account

If you are willing to absorb your own Snowflake usage costs to avoid shared-queue delays, you can host the Spider 2.0 datasets in your own Snowflake project by following the steps below.

## 1. Request Access

Send an email to lfy79001@gmail.com with the following details:
- Your Snowflake account identifier in the format `<ORG_NAME>.<ACCOUNT_NAME>` (example: `NDSOEBE.RAI_DEV_XXXX_AWS_US_WEST_2_TEST`).
- Your Snowflake cloud provider and region (for example, `AWS us-west-2`). If we are on different regions or clouds, we may need to set up a Snowflake Listing or use the repack/share flow.

We will grant your account access to the Spider 2.0 Secure Data Share once we have this information.

## 2. Accept the Secure Share

After access has been granted, accept the share and configure your environment following Steps 4–5 in the [`spider2-data-share`](https://github.com/lfy79001/spider2-data-share) repository. Use that repository’s tooling for the overall migration flow, and make sure you execute Steps 4 and 5—they should succeed once the share is available.

For Step 4, you can run the SQL below to create the merged database from the secure share and grant the required privileges:

```sql
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE DATABASE SPIDER2_MERGED_250922
  FROM SHARE "SDB71929".SHARE_FOR_SPIDER2_DB;
GRANT IMPORTED PRIVILEGES ON DATABASE SPIDER2_MERGED_250922 TO ROLE SYSADMIN;

USE ROLE SYSADMIN;
SHOW SCHEMAS IN DATABASE SPIDER2_MERGED_250922;
```

Then continue with Step 5 in the `spider2-data-share` guide to unpack the merged database into the individual target databases.

## 3. Important Limitations

Databases for examples whose identifiers do **not** start with `sf_` cannot be shared yet. There are currently 18 such examples; you must continue to use the public Spider 2.0 Snowflake project for those cases even after you migrate the rest of the data.
