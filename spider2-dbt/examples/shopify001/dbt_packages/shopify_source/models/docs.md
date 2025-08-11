{% docs _fivetran_synced %}

The time when a record was last updated by Fivetran.
 
{% enddocs %}

{% docs _fivetran_deleted %}

Boolean representing whether the record was soft-deleted in Shopify.
 
{% enddocs %}

{% docs source_relation %}

The schema or database this record came from if you are making use of the `shopify_union_schemas` or `shopify_union_databases` variables, respectively. Empty string if you are not using either of these variables to union together multiple Shopify connectors.
 
{% enddocs %}