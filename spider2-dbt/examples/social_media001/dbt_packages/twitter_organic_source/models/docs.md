{% docs _fivetran_synced -%} When the record was last synced by Fivetran. {%- enddocs %}

{% docs is_most_recent_record %} Boolean representing whether a record is the most recent version of that record. All records should have this value set to True given we filter on it. {% enddocs %}