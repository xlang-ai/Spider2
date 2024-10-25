#!/bin/bash

cd /workspace

# 启动 ClickHouse 服务器，并捕获日志
nohup ./clickhouse server > /var/log/clickhouse.log 2>&1 &

echo "ClickHouse server started successfully."

# 执行提供的命令，默认为 bash
exec "$@"
