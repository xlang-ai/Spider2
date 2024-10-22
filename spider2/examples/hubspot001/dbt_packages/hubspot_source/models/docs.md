{% docs _fivetran_synced %}
Timestamp of when Fivetran synced a record.
{% enddocs %}

{% docs _fivetran_deleted %}
Boolean indicating whether a record has been deleted in Hubspot and/or inferred deleted in Hubspot by Fivetran; _fivetran_deleted and is_deleted fields are equivalent. 
{% enddocs %}

{% docs _fivetran_end %}
The (UTC DATETIME) when a record became inactive in the source database.
{% enddocs %}

{% docs _fivetran_start %}
The (UTC DATETIME) to keep track of the time when a record is first created or modified in the source database.
{% enddocs %}

{% docs portal_id %}
The hub ID.
{% enddocs %}

{% docs is_deleted %}
Boolean indicating whether a record has been deleted in Hubspot and/or inferred deleted in Hubspot by Fivetran; _fivetran_deleted and is_deleted fields are equivalent.
{% enddocs %}

{% docs history_name %}
The name of the field being changed.
{% enddocs %}

{% docs history_source %}
The source (reason) of the change.
{% enddocs %}

{% docs history_source_id %}
The ID of the object that caused the change, if applicable.
{% enddocs %}

{% docs history_timestamp %}
The timestamp the changed occurred.
{% enddocs %}

{% docs history_value %}
The new value of the field.
{% enddocs %}

{% docs email_event_browser %}
A JSON object representing the browser which serviced the event. Its comprised of the properties: 'name', 'family', 'producer', 'producer_url', 'type', 'url', 'version'.
{% enddocs %}

{% docs email_event_ip_address %}
The contact's IP address when the event occurred.
{% enddocs %}

{% docs email_event_location %}
A JSON object representing the location where the event occurred. It's comprised of the properties: 'city', 'state', 'country'.
{% enddocs %}

{% docs email_event_user_agent %}
The user agent responsible for the event, e.g. “Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.36”
{% enddocs %}

