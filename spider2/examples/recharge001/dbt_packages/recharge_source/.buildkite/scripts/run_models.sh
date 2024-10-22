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
dbt seed --target "$db" --full-refresh
dbt compile --target "$db"
dbt run --target "$db" --full-refresh
dbt test --target "$db"
dbt run --vars '{recharge__using_orders: false, recharge__checkout_enabled: true, recharge__one_time_product_enabled: false, recharge__address_passthrough_columns: [cart_attribute_id]}' --target "$db" --full-refresh
dbt test --vars '{recharge__using_orders: false, recharge__checkout_enabled: true, recharge__one_time_product_enabled: false, recharge__address_passthrough_columns: [cart_attribute_id]}' --target "$db"

dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"
