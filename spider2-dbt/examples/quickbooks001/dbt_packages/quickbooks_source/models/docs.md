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

{% docs source_relation %}
The source of the record if the unioning functionality is being used. If not this field will be null. 
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