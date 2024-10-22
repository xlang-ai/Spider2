{% test test_positive_values(model,column_name) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} < 1
LIMIT 1

{% endtest %}