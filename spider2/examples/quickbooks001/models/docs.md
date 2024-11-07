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



# Table Definitions
{% docs account_table %}
Table containing components of a Chart Of Accounts and is part of a ledger. It is used to record a total monetary amount allocated against a specific use. Accounts are one of five basic types: asset, liability, revenue (income), expenses, or equity.
{% enddocs %}

{% docs address_table %}
Table containing address details.
{% enddocs %}

{% docs bill_line_table %}
Table containing distinct line items from bills within the `bill` table.
{% enddocs %}

{% docs bill_linked_txn_table %}
Mapping table containing bill payment transactions linked to a bill.
{% enddocs %}

{% docs bill_payment_line_table %}
Table containing individual line items of a bill payment, which are recorded within the `bill_payment` table.
{% enddocs %}

{% docs bill_payment_table %}
Table containing payment transactions bills that the business owner receives from a vendor for goods or services purchased from the vendor.
{% enddocs %}

{% docs bill_table %}
Table containing AP transactions representing a request-for-payment from a third party for goods/services rendered, received, or both.
{% enddocs %}

{% docs bundle_item_table %}
Mapping table containing all bundle and item combinations.
{% enddocs %}

{% docs bundle_table %}
Table containing all bundles possible to be used within an invoice.
{% enddocs %}

{% docs credit_card_payment_txn_table %}
Table containing all credit card payment transactions.
{% enddocs %}

{% docs credit_memo_line_table %}
Table containing individual records of credit memos.
{% enddocs %}

{% docs credit_memo_table %}
Table containing credit memo records. A credit memo is a refund or credit of payment or part of a payment for goods or services that have been sold.
{% enddocs %}

{% docs customer_table %}
Table containing customers of which are consumers of the service or product that your business offers.
{% enddocs %}

{% docs department_table %}
Table containing records representing physical locations such as stores, and sales regions.
{% enddocs %}

{% docs deposit_line_table %}
Table containing individual line items comprising the deposit.
{% enddocs %}

{% docs deposit_table %}
Table containing records of transactions that record on or more deposits of a customer payment or a new direct deposit.
{% enddocs %}

{% docs estimate_line_table %}
Table containing line item records of an estimate.
{% enddocs %}

{% docs estimate_table %}
Table containing estimates. An estimate represents a proposal for a financial transaction from a business to a customer for goods or services proposed to be sold, including proposed pricing.
{% enddocs %}

{% docs invoice_line_bundle_table %}
Table containing lines of an invoice which were bundled.
{% enddocs %}

{% docs invoice_line_table %}
Table containing individual records from invoices.
{% enddocs %}

{% docs invoice_linked_txn_table %}
Mapping table for invoices records to respective estimate and payment objects.
{% enddocs %}

{% docs invoice_table %}
Table containing invoice records. An Invoice represents a sales form where the customer pays for a product or service later.
{% enddocs %}

{% docs item_table %}
Table containing item records. An item is a thing that your company buys, sells, or re-sells, such as products and services.
{% enddocs %}

{% docs journal_entry_line_table %}
Table containing individual line items of a transaction associated with a journal entry.
{% enddocs %}

{% docs journal_entry_table %}
Table containing journal entry transactions.
{% enddocs %}

{% docs payment_line_table %}
Table containing individual line items recorded within a payment.
{% enddocs %}

{% docs payment_table %}
Table containing all payment records. The payment can be applied for a particular customer against multiple Invoices and Credit Memos. It can also be created without any Invoice or Credit Memo, by just specifying an amount.
{% enddocs %}

{% docs purchase_line_table %}
Table containing individual line items of a transaction associated with a purchase.
{% enddocs %}

{% docs purchase_order_line_table %}
Table containing individual line items of a transaction associated with a purchase order.
{% enddocs %}

{% docs purchase_order_linked_txn_table %}
Mapping table for purchase order records to respective bill and purchase objects.
{% enddocs %}

{% docs purchase_order_table %}
Table containing records of purchase orders (PO).
{% enddocs %}

{% docs purchase_table %}
Table containing records of purchase expenses.
{% enddocs %}

{% docs refund_receipt_line_table %}
Table containing individual line items of a refund transaction.
{% enddocs %}

{% docs refund_receipt_table %}
Table containing refunds to the customer for a product or service that was provided.
{% enddocs %}

{% docs sales_receipt_line_table %} 
Table containing individual line items of a sales transaction.
{% enddocs %}

{% docs sales_receipt_table %}
Table containing sales receipts that are given to a customer. A sales receipt, payment is received as part of the sale of goods and services. The sales receipt specifies a deposit account where the customer's payment is deposited.
{% enddocs %}


{% docs transfer_table %}
Table containing records of transfers. A Transfer represents a transaction where funds are moved between two accounts from the company's QuickBooks chart of accounts.
{% enddocs %}

{% docs vendor_credit_line_table %}
Table containing individual vendor credit line items.
{% enddocs %}

{% docs vendor_credit_table %}
Table containing all vendor credit records. A vendor credit is an accounts payable transaction that represents a refund or credit of payment for goods or services.
{% enddocs %}

{% docs vendor_table %}
Table containing all vendor records. A vendor is the seller from whom your company purchases any service or product.
{% enddocs %}


# Field Definitions and References
{% docs account_id %} 
The identifier of the account associated 
{% enddocs %}

{% docs amount %}
Monetary amount of 
{% enddocs %}

{% docs class_id %}
Reference to the class associated 
{% enddocs %}

{% docs created_at %}
Timestamp of the creation date 
{% enddocs %}

{% docs currency_id %}
Reference to the currency 
{% enddocs %}

{% docs customer_id %}
Reference to the customer associated 
{% enddocs %}

{% docs department_id %}
Reference to the department 
{% enddocs %}

{% docs id %}
Unique identifier of the
{% enddocs %}

{% docs item_id %}
Reference to the item 
{% enddocs %}

{% docs _fivetran_deleted %}
Boolean created by Fivetran to indicate whether the record has been deleted.
{% enddocs %}