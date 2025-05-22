## Syncing all of your fields from the Salesforce History Mode connector
When creating these new History Mode models, our hypothesis was that the primary reason customers would leverage this data would be to view changes in historical records.

Our normal process is to allow customers to pick and choose the custom fields they bring into their end models. However, omitting any fields that are being synced will lead to new rows of historical records having duplicate data, thus missing out on the potentially. 

Our conclusion was that there is more value for a customer to leverage the history tables if they are syncing all fields they are using, and can thus view all the historical changes in the records they are using. 

There is the drawback of a significant amount of data processing and very large tables with a huge number of columnar values, but we felt this version made the most sense for customers who really want to unlock historical data on their Salesforce tables. 

We are open to feedback on how to improve these history models at all time, [so please contact us directly via our many channels](https://github.com/fivetran/dbt_salesforce_source#-how-is-this-package-maintained-and-can-i-contribute)!