{% test empty_table(model) %}

    SELECT COALESCE(COUNT(*),0) AS records
    FROM {{ model }}
    HAVING COUNT(*) = 0

{% endtest %}