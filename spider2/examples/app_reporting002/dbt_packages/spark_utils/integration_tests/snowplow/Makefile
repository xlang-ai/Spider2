
test-databricks:
	dbt deps
	dbt seed --target databricks --full-refresh
	dbt run --target databricks --full-refresh --vars 'update: false'
	dbt run --target databricks --vars 'update: true'
	dbt test --target databricks
