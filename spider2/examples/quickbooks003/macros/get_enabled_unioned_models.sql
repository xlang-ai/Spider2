{% macro get_enabled_unioned_models(unioned_models = [ 
    'bill',
    'credit_memo',
    'deposit',
    'invoice',
    'journal_entry',
    'payment',
    'refund_receipt',
    'sales_receipt',
    'transfer',
    'vendor_credit']) %} 

{% set enabled_unioned_models = [] %}

{{ enabled_unioned_models.append(ref('int_quickbooks__purchase_double_entry')) }}

{% for unioned_model in unioned_models %}  
    {% if var('using_' ~ unioned_model, True) %}
        {{ enabled_unioned_models.append(ref('int_quickbooks__' ~ unioned_model ~ '_double_entry')) }}
    {% endif %}
 {% endfor %}   
    
{% if var('using_bill', True) %}
    {{ enabled_unioned_models.append(ref('int_quickbooks__bill_payment_double_entry')) }}
{% endif %}

{% if var('using_credit_card_payment_txn', False) %}
    {{ enabled_unioned_models.append(ref('int_quickbooks__credit_card_pymt_double_entry')) }}
{% endif %}

{{ return(enabled_unioned_models) }}

{% endmacro %}