#!/bin/bash

# Define a function to execute a command and check the return value
execute_command() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Command execution failed: $1"
        return 1
    fi
}

# Array of commands
commands=("apt update" "pip install --upgrade pip" "apt install -y postgresql")

# Loop to execute commands until all are successful
for cmd in "${commands[@]}"; do
    while true; do
        execute_command $cmd && break
    done
done



service postgresql start

su - postgres <<EOF
psql -c "CREATE USER xlanglab WITH PASSWORD '123456';"
psql -c "CREATE DATABASE xlangdb;"
psql -c "ALTER DATABASE xlangdb OWNER TO xlanglab;"
EOF

echo "listen_addresses = 'localhost'" >> /etc/postgresql/15/main/postgresql.conf
echo "listen_addresses = '*'" >> /etc/postgresql/15/main/postgresql.conf
touch ~/.pgpass
chmod 600 ~/.pgpass
echo "localhost:5432:xlangdb:xlanglab:123456" >> ~/.pgpass
echo 'host    all             all             0.0.0.0/0               md5' >> /etc/postgresql/15/main/pg_hba.conf

echo 'service postgresql restart' >> ~/.bashrc
service postgresql restart

cd /workspace