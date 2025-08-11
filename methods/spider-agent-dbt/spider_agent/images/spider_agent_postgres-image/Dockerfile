FROM python:3.11

WORKDIR /workspace

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python packages
RUN pip install --upgrade pip

RUN pip install google-cloud-bigquery pyarrow db-dtypes pandas matplotlib scikit-learn seaborn numpy scipy statsmodels xgboost plotly tabulate snowflake-connector-python duckdb openpyxl
RUN pip install dbt-postgres
# Set the default command to run when starting the container


COPY init.sh .

RUN chmod +x init.sh && ./init.sh

RUN rm init.sh

CMD ["/bin/bash"]