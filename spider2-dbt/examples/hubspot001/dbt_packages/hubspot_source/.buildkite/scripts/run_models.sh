#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
if [ "$db" = "databricks-sql" ]; then
dbt seed --vars '{hubspot_schema: hubspot_sqlw_tests}' --target "$db" --full-refresh
dbt compile --vars '{hubspot_schema: hubspot_sqlw_tests}' --target "$db"
dbt run --vars '{hubspot_schema: hubspot_sqlw_tests}' --target "$db" --full-refresh
dbt test --vars '{hubspot_schema: hubspot_sqlw_tests}' --target "$db"
dbt run --vars '{hubspot_schema: hubspot_sqlw_tests, hubspot_marketing_enabled: true, hubspot_contact_merge_audit_enabled: true, hubspot_sales_enabled: false}' --target "$db"
dbt run --vars '{hubspot_schema: hubspot_sqlw_tests, hubspot_marketing_enabled: false, hubspot_sales_enabled: true, hubspot_merged_deal_enabled: true, hubspot__pass_through_all_columns: true, hubspot_using_all_email_events: false, hubspot_owner_enabled: false}' --target "$db"
dbt test --vars '{hubspot_schema: hubspot_sqlw_tests}' --target "$db"
else
dbt seed --target "$db" --full-refresh
dbt run --target "$db" --full-refresh
dbt test --target "$db"            
dbt run --vars '{hubspot_marketing_enabled: true, hubspot_sales_enabled: false}' --target "$db"
dbt run --vars '{hubspot_marketing_enabled: true, hubspot_contact_merge_audit_enabled: true, hubspot_sales_enabled: false}' --target "$db"
dbt run --vars '{hubspot_marketing_enabled: false, hubspot_sales_enabled: true}' --target "$db"
dbt run --vars '{hubspot_marketing_enabled: false, hubspot_sales_enabled: false}' --target "$db"
dbt run --vars '{hubspot_deal_enabled: true, hubspot_sales_enabled: true, hubspot_merged_deal_enabled: true}' --target "$db"
dbt run --vars '{hubspot__pass_through_all_columns: true, hubspot_service_enabled: true, hubspot_using_all_email_events: false}' --target "$db"
dbt test --target "$db"
fi
dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"
