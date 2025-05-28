# How to Change Snowflake Compute Warehouse

If you find that your database query response time is slow, you may need to update the Snowflake compute warehouse used in your configuration. This guide explains how to modify your `snowflake_credential.json` file to switch to a faster warehouse with fewer users and no queuing.



## Default Configuration

For users who registered before May 28th, the default `snowflake_credential.json` file looks like this:

```json
{
    "user": "your_username",
    "password": "your_password",
    "account": "RSRSBDK-YDB67606"
}
```

With this configuration, the system automatically uses the default warehouse `COMPUTE_WH_PARTICIPANT`, which may experience high traffic and result in longer query times.

## Why Change the Warehouse?

The default warehouse (`COMPUTE_WH_PARTICIPANT`) may experience slower query performance due to high usage. To improve query speed, you can switch to another warehouse: `COMPUTE_WH_PARTICIPANT_1`. These warehouses have fewer users, faster computation, and no queuing.


## How to Update the Warehouse

If you notice slow query response times, you can manually modify your `snowflake_credential.json` file to use another warehouse:

```json
{
    "user": "your_username",
    "password": "your_password",
    "account": "RSRSBDK-YDB67606",
    "warehouse": "COMPUTE_WH_PARTICIPANT_1" 
}
```
