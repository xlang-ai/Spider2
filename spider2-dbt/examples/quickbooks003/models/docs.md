# Table Definitions

{% docs ap_ar_enhanced_table %}
Table that unions all accounts payable records from int_quickbooks__bill_join and all accounts receivable records from int_quickbooks__invoice_join while also adding customer, vendor, address, and department level detail to the accounts payable and receivable records. Further, date and amount
calculations are included to show if the payable/receivable has been fully paid and/or paid on time.
{% enddocs %}

{% docs cash_flow_statement_table %}
Table that provides all line items necessary to construct a cash flow statement.
{% enddocs %}

{% docs expenses_sales_enhanced_table %}
Table that unions all expense records from int_quickbooks__expenses_union and all sales records from the int_quickbooks__sales_union while also adding  customer, vendor, and department level detail to the expense and sales records.
{% enddocs %}

{% docs general_ledger_table %}
Table that unions all records from each model within the double_entry_transactions directory. The table end result is a comprehensive general ledger with an offsetting debit and credit entry for each transaction.
{% enddocs %}

{% docs general_ledger_by_period_table %}
Table that pulls general ledger account level balances per period from int_quickbooks__general_ledger_balances while also creating an offsetting Retained Earnings entry for Revenue - Expenses per year to be added as single Equity line balance per year.
{% enddocs %}

{% docs profit_and_loss_table %}
Table containing all revenue and expense account classes by calendar year and month enriched with account type, class, and parent information.
{% enddocs %}

# Field Definitions and References

{% docs account_class %}
Class of the account associated 
{% enddocs %}

{% docs account_name %}
Name of the account associated 
{% enddocs %}

{% docs account_number %}
User defined number of the account.
{% enddocs %}

{% docs account_ordinal %}
Integer value to order the account within final financial statement reporting. The customer can also configure the ordinal; [see the README for details](https://github.com/fivetran/dbt_quickbooks/blob/main/README.md#customize-the-account-ordering-of-your-profit-loss-and-balance-sheet-models)
{% enddocs %}

{% docs account_sub_type %}
Sub type of the account associated 
{% enddocs %}

{% docs account_type %}
The type of account associated 
{% enddocs %}

{% docs calendar_date %}
Timestamp of the first calendar date of the month. This is slated to be deprecated, and the fields `period_first_day` and `period_last_day` are both offered as replacements, depending on how your company performs their financial reporting.
{% enddocs calendar_date %}

{% docs is_sub_account %}
Boolean indicating whether the account is a sub account (true) or a parent account (false).
{% enddocs %}

{% docs parent_account_name %}
The parent account name. If the account is the parent account then the account name is recorded.
{% enddocs %}

{% docs parent_account_number %}
The parent account number. If the account is the parent account then the account number is recorded.
{% enddocs %}

{% docs source_relation %}
The source of the record if the unioning functionality is being used. If not this field will be null. 
{% enddocs %}

{% docs transaction_date %}
The date that the transaction occurred.
{% enddocs %}

{% docs transaction_id %}
Unique identifier of the transaction 
{% enddocs %}
