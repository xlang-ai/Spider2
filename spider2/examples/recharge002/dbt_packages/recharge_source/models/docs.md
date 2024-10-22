{% docs _fivetran_deleted %}
Boolean created by Fivetran to indicate whether the record has been deleted.
{% enddocs %}

{% docs _fivetran_id %}
Unique ID used by Fivetran to sync and dedupe data.
{% enddocs %}

{% docs _fivetran_synced %}
Timestamp of when Fivetran synced a record.
{% enddocs %}

{% docs address_id %}
The unique identifier of the address.
{% enddocs %}

{% docs charge_id %}
The unique identifier of the charge.
{% enddocs %}

{% docs customer_id %}
The unique identifier of the customer.
{% enddocs %}

{% docs discount_id %}
The unique identifier of the discount.
{% enddocs %}

{% docs order_id %}
The unique identifier of the order.
{% enddocs %}

{% docs subscription_id %}
The unique identifier of the subscription.
{% enddocs %}

{% docs charge_status %}
The status of the charge. Possible values are SUCCESS, ERROR, QUEUED, SKIPPED, REFUNDED, PARTIALLY_REFUNDED.
{% enddocs %}

{% docs discount_status %}
The status of the discount, accepted values - enabled, disabled, fully_disabled.
{% enddocs %}

{% docs order_status %}
The status of the order. Possible values are SUCCESS, ERROR, QUEUED, CANCELLED.
{% enddocs %}

{% docs subscription_status %}
The status of the subscription. Possible values are ACTIVE, CANCELLED, EXPIRED.
{% enddocs %}

{% docs type %}
Possible values are CHECKOUT, RECURRING.
{% enddocs %}

 "{{ doc('address_id') }}"