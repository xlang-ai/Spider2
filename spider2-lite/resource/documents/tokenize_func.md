# Requirements

The following shows the SQL operations you must perform. Please implement the corresponding functionality in your SQL code according to the description.

## `tokenise_no_stop`

### Description
Removes common stopwords from a text string and tokenizes the remaining content into an array of words. This function is essential for natural language processing tasks where common words (like "and", "the", etc.) that offer little value in understanding the text's meaning are filtered out to focus on more significant words.

### SQL Definition

Please use Snowflake SQL. The following shows an example of this operation in BigQuery SQL.

```sql
tokenise_no_stop(text STRING)
AS (
(
    SELECT ARRAY_AGG(word) FROM UNNEST(REGEXP_EXTRACT_ALL(
                                REGEXP_REPLACE(text, r'’|\'s(\W)', r'\1'),
                                r'((?:\d+(?:,\d+)*(?:\.\d+)?)+|(?:[\w])+)')) AS word
    WHERE LOWER(word) not in UNNEST(['a', 'about', 'above', 'after', 'again', 'against', 'ain', 'all', 'am', 'an', 'and', 'any', 'are', 'aren', 'arent', 'as', 'at', 'be', 'because', 'been', 'before', 'being', 'below', 'between', 'both', 'but', 'by', 'can', 'couldn', 'couldnt', 'd', 'did', 'didn', 'didnt', 'do', 'does', 'doesn', 'doesnt', 'doing', 'don', 'dont', 'down', 'during', 'each', 'few', 'for', 'from', 'further', 'had', 'hadn', 'hadnt', 'has', 'hasn', 'hasnt', 'have', 'haven', 'havent', 'having', 'he', 'her', 'here', 'hers', 'herself', 'him', 'himself', 'his', 'how', 'i', 'if', 'in', 'into', 'is', 'isn', 'isnt', 'it', 'its', 'itself', 'just', 'll', 'm', 'ma', 'me', 'mightn', 'mightnt', 'more', 'most', 'mustn', 'mustnt', 'my', 'myself', 'needn', 'neednt', 'no', 'nor', 'not', 'now', 'o', 'of', 'off', 'on', 'once', 'only', 'or', 'other', 'our', 'ours', 'ourselves', 'out', 'over', 'own', 're', 's', 'same', 'shan', 'shant', 'she', 'shes', 'should', 'shouldn', 'shouldnt', 'shouldve', 'so', 'some', 'such', 't', 'than', 'that', 'thatll', 'the', 'their', 'theirs', 'them', 'themselves', 'then', 'there', 'these', 'they', 'this', 'those', 'through', 'to', 'too', 'under', 'until', 'up', 've', 'very', 'was', 'wasn', 'wasnt', 'we', 'were', 'weren', 'werent', 'what', 'when', 'where', 'which', 'while', 'who', 'whom', 'why', 'will', 'with', 'won', 'wont', 'wouldn', 'wouldnt', 'y', 'you', 'youd', 'youll', 'your', 'youre', 'yours', 'yourself', 'yourselves', 'youve'])
    )
);
```
