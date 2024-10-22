
test-spark:
	dbt deps
	dbt seed --target spark --full-refresh --no-version-check
	dbt run --target spark --full-refresh --no-version-check
	dbt test --target spark --no-version-check

test-databricks:
	dbt deps
	dbt seed --target databricks --full-refresh
	dbt run --target databricks --full-refresh
	dbt test --target databricks
