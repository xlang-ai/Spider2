# Installation 

The following installation guidance is derived from [the original repository of Dail-SQL](https://github.com/BeachWang/DAIL-SQL).

Set up the Python environment:
```
conda create -n DAIL-SQL python=3.8
conda activate DAIL-SQL
cd spider2-lite/baselines/dailsql
pip install -r requirements.txt
python nltk_downloader.py
```

Download the model for spacy:
```
pip install https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.5.0/en_core_web_sm-3.5.0-py3-none-any.whl
```

# Running

Export your OpenAI API key:
```
export OPENAI_API_KEY=YOUR_OPENAI_API_KEY
```

Replace the VPN launch approach below with your own method, to gain access to OpenAI and Google BigQuery:
```
export https_proxy=http://127.0.0.1:15777 http_proxy=http://127.0.0.1:15777
```

Finally, simply run :laughing::
```
bash run.sh
```
this script automatically conducts all procedures: 1) data preprocess, 2) executing Dail-SQL, 3) evaluation. You can find the predicted SQL in `spider2-lite/baselines/dailsql/postprocessed_data`.


# Evaluation

## Experimental Setting

- `DailSQL` utilizes the Code Representation (CR) prompt from the original DailSQL paper. To accommodate the complexity of the Spider2 dataset, we enhance the prompt by **incorporating column descriptions, sampled rows, and external knowledge**.
- The Score [w/ Func & w/ Plan] represents an oracle setting, utilizing reference plans and gold SQL functions for a set of analytical experiments.
- Given the large number of tables and columns in the Spider2 dataset, we leverage **GPT-4o** with a 128k context window to prevent prompt size limitations.

The performance is shown as:

<!-- - `DailSQL+Func+Plan+Debug`: Further add a SQL Debug module, which refines erroneous SQL queries according to error feedback information. -->
  

| Method                     | Score   | Score [w/ Func & w/ Plan] |
| -------------------------- | ---- | --- |
| DailSQL + GPT-4o   | 9.40% (30/319) | 12.54% (40/319) |

## Prompts

Take `bq076` as example, the prompt of `DailSQL` is as:
```
/* Given the following database schema: */
CREATE TABLE "crime"
(
    "unique_key" INT64,
    "case_number" STRING,
    "date" TIMESTAMP,
    "block" STRING,
    "iucr" STRING,
    "primary_type" STRING,
    "description" STRING,
    "location_description" STRING,
    "arrest" BOOL,
    "domestic" BOOL,
    "beat" INT64,
    "district" INT64,
    "ward" INT64,
    "community_area" INT64,
    "fbi_code" STRING,
    "x_coordinate" FLOAT64,
    "y_coordinate" FLOAT64,
    "year" INT64,
    "updated_on" TIMESTAMP,
    "latitude" FLOAT64,
    "longitude" FLOAT64,
    "location" STRING
)

/* Sample rows from the tables: */
table crime:
|   unique_key | case_number   | date                      | block             |   iucr | primary_type            | description    | location_description   | arrest   | domestic   |   beat |   district |   ward |   community_area |   fbi_code |   x_coordinate |   y_coordinate |   year | updated_on                |   latitude |   longitude | location                      |
|-------------:|:--------------|:--------------------------|:------------------|-------:|:------------------------|:---------------|:-----------------------|:---------|:-----------|-------:|-----------:|-------:|-----------------:|-----------:|---------------:|---------------:|-------:|:--------------------------|-----------:|------------:|:------------------------------|
|     13350090 | JH130429      | 2023-12-02 20:00:00+00:00 | 0000X E WACKER PL |   0281 | CRIMINAL SEXUAL ASSAULT | NON-AGGRAVATED | HOTEL / MOTEL          | False    | False      |    111 |          1 |     42 |               32 |         02 |    1.17696e+06 |    1.90214e+06 |   2023 | 2024-01-29 15:40:30+00:00 |    41.8868 |    -87.6256 | (41.886814897, -87.625592678) |

/* Answer the following without any explanation and don't use ```sql```: Which month generally has the greatest number of motor vehicle thefts in 2016? */
SELECT 
```
The additional prompt of setting [w/ Func & w/ Plan] is as:
```
...

/* Potential functions with their usage: */
date-functions/DATE: Constructs a ` DATE ` value.
date-functions/EXTRACT: Extracts part of a date from a ` DATE ` value.
datetime-functions/EXTRACT: Extracts part of a date and time from a ` DATETIME ` value.
interval-functions/EXTRACT: Extracts part of an ` INTERVAL ` value.
numbering-functions/RANK: Gets the rank (1-based) of each row within a window.
time-functions/EXTRACT: Extracts part of a ` TIME ` value.
timestamp-functions/EXTRACT: Extracts part of a ` TIMESTAMP ` value.

/* A plan that is useful for guiding the generation of components of a complete SQL query: */
Which month generally has the greatest number of motor vehicle thefts?
The following query summarizes the number of MOTOR VEHICLE THEFT incidents for each year and month, and ranks the month’s total from 1 to 12. Then, the outer SELECT clause limits the final result set to the first overall ranking for each year. According to the data, in 3 of the past 10 years, December had the highest number of car thefts

...
```

<!-- The additional prompt of `+debug` is as:
```
/* Wrong Query */
SELECT COUNT(DISTINCT last_7_days.user_pseudo_id) FROM ( SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210101` UNION ALL SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210102` UNION ALL SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210103` UNION ALL SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210104` UNION ALL SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210105` UNION ALL SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210106` UNION ALL SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210107` ) last_7_days LEFT JOIN ( SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210106` UNION ALL SELECT user_pseudo_id FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210107` ) last_2

/* Error Info */
400 LEFT JOIN must have an immediately following ON or USING clause at [1:818]; reason: invalidQuery, location: query, message: LEFT JOIN must have an immediately following ON or USING clause at [1:818]
``` -->


# Error Analysis

For `DailSQL` in setting [w/ Func & w/ Plan], all incorrect instances can be categorized as follows:

| Error Category                             | Description                               | Count  |
| ------------------------------------ | ----------------------------------------- | ------ |
| Prompt length exceed                 | Exceeds limit when all schemas are included in the prompt.  | 13     |
| SQL syntax error                     | Expected xxx, but got xxx; Unexpected xxx.     |  40     |
| Request a schema that does not exist | NoSuchTable; NoSuchColumn.                 | 37 |
| Result error                         | Request incorrect tables or columns, join error, etc. | 13     |
