FROM python:3.11

WORKDIR /workspace

# Update and install dependencies
RUN apt-get update && apt-get install --fix-missing -y \
    build-essential \
    libicu-dev \
    libreadline-dev \
    libltdl7 \
    libssl-dev \
    libpam0g \
    libpthread-stubs0-dev \
    libpoco-dev \
    libunwind8 \
    libunwind-dev \
    libboost-all-dev \
    libcrypto++-dev \
    zlib1g-dev \
    curl \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python packages
RUN pip install --upgrade pip

RUN pip install pyarrow db-dtypes pandas numpy scipy tabulate clickhouse_driver

# Install ClickHouse
RUN curl https://clickhouse.com/ | sh

# 自动接受许可协议
ENV CLICKHOUSE_ACCEPT_AND_CONSIDER_NOTED=1

# Copy the entrypoint script
COPY entrypoint.sh .

# 设置可执行权限
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

# Default command
CMD ["bash"]
