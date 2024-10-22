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
dbt seed --vars '{jira_schema: jira_source_integrations_tests_sqlw}' --target "$db" --full-refresh
dbt compile --vars '{jira_schema: jira_source_integrations_tests_sqlw}' --target "$db"
dbt run --vars '{jira_schema: jira_source_integrations_tests_sqlw}' --target "$db" --full-refresh
dbt test --vars '{jira_schema: jira_source_integrations_tests_sqlw}' --target "$db"
dbt run --vars '{jira_schema: jira_source_integrations_tests_sqlw, jira_using_priorities: false, jira_using_sprints: false, jira_using_components: false, jira_using_versions: false, jira_field_grain: 'field_name'}' --target "$db" --full-refresh
dbt test --vars '{jira_schema: jira_source_integrations_tests_sqlw, jira_using_priorities: false, jira_using_sprints: false, jira_using_components: false, jira_using_versions: false, jira_field_grain: 'field_name'}' --target "$db"

else
dbt seed --target "$db" --full-refresh
dbt compile --target "$db"
dbt run --target "$db" --full-refresh
dbt test --target "$db"
dbt run --vars '{jira_using_priorities: false, jira_using_sprints: false, jira_using_components: false, jira_using_versions: false, jira_field_grain: 'field_name'}' --target "$db" --full-refresh
dbt test --vars '{jira_using_priorities: false, jira_using_sprints: false, jira_using_components: false, jira_using_versions: false, jira_field_grain: 'field_name'}' --target "$db"
fi

dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"