{% docs billing_type %}
The source type of the invoice.
{% enddocs %}

{% docs created_at %}
The date the line item was created. 
{% enddocs %}

{% docs currency %}
The currency of the line item.
{% enddocs %}

{% docs customer_city %}
City in which the customer associated to the invoice is located.
{% enddocs %}

{% docs customer_company %}
Company name of the customer associated to the invoice.
{% enddocs %}

{% docs customer_country %}
Country in which the customer associated to the invoice is located.
{% enddocs %}

{% docs customer_email %}
Email of the customer associated to the invoice.
{% enddocs %}

{% docs customer_id %}
Unique identifier of the customer associated with the invoice.
{% enddocs %}

{% docs customer_created_at %}
Date the customer was created in Zuora.
{% enddocs %}

{% docs customer_level %}
Will either be 'account' (company level) or 'customer' (individual level). For Recurly, the level is 'customer'.
{% enddocs %}

{% docs customer_name %}
Name of the customer associated with the invoice.
{% enddocs %}

{% docs discount_amount %}
Total discount amount of the invoice.
{% enddocs %}

{% docs header_id %}
The invoice_id.
{% enddocs %}

{% docs header_status %}
Status of the invoice
{% enddocs %}

{% docs line_item_id %}
The invoice_item_id.
{% enddocs %}

{% docs line_item_index %}
Generated index which numbers the invoice items.
{% enddocs %}

{% docs payment_at %}
The effective date of the payment.
{% enddocs %}

{% docs fee_amount %}
There are no fees in Zuora. Therefore, this will always be null.
{% enddocs %}


{% docs payment_id %}
The invoice_payments payment_id.
{% enddocs %}

{% docs payment_method %}
Name of the payment method.
{% enddocs %}

{% docs payment_method_id %}
Unique identifier of the payment method.
{% enddocs %}

{% docs product_id %}
Unique identifier of the product.
{% enddocs %}

{% docs product_name %}
Name of the product.
{% enddocs %}

{% docs product_type %}
Product type attributed to the product.
{% enddocs %}

{% docs quantity %}
Number of items listed on the line item.
{% enddocs %}

{% docs record_type %}
Header or line_item. Means invoice or line item record respectively.
{% enddocs %}

{% docs refund_amount %}
Total refund amount.
{% enddocs %}

{% docs subscription_id %}
Unique identifier of the subscription.
{% enddocs %}

{% docs subscription_plan %}
Rate plan name of the subscription.
{% enddocs %}

{% docs subscription_period_ended_at %}
Subscription's current period end
{% enddocs %}

{% docs subscription_period_started_at %}
Subscription's current period start
{% enddocs %}

{% docs subscription_status %}
Status of the subscription.
{% enddocs %}

{% docs tax_amount %}
Amount of tax attributed to the invoice.
{% enddocs %}

{% docs total_amount %}
Total amount attributed to the line item.
{% enddocs %}

{% docs transaction_type %}
The type of transaction. Either charge, discount, prepayment, or tax.
{% enddocs %}

{% docs unit_amount %}
Amount attributed to each quantity item on the invoice.
{% enddocs %}