
WITH
  PurchaseEvents AS (
SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201201 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201202 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201203 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201204 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201205 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201206 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201207 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201208 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201209 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201210 WHERE event_name = 'purchase' 
UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201211 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201212 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201213 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201214 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201215 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201216 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201217 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201218 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201219 WHERE event_name = 'purchase' 
UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201220 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201221 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201222 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201223 WHERE event_name = 'purchase' 
UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201224 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201225 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201226 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201227 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201228 WHERE event_name = 'purchase' 
UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201229 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201230 WHERE event_name = 'purchase' UNION ALL SELECT user_pseudo_id, PARSE_JSON(items) as items FROM GA4.GA4_OBFUSCATED_SAMPLE_ECOMMERCE.EVENTS_20201231 WHERE event_name = 'purchase'
),

ProductABuyers AS (
SELECT
  user_pseudo_id,
  item.value:item_name::STRING AS item_name,
  item.value:quantity::STRING AS quantity,
FROM
  PurchaseEvents,
  LATERAL FLATTEN(input => items) AS item
WHERE
  item_name = 'Google Navy Speckled Tee'
),

ITEM_QUANTITY AS (
    SELECT
      item.value:item_name::STRING AS item_name,
      item.value:quantity::STRING AS quantity
    FROM
      PurchaseEvents,
      LATERAL FLATTEN(input => items) AS item
    WHERE
      user_pseudo_id IN (SELECT user_pseudo_id FROM ProductABuyers)
      AND item_name != 'Google Navy Speckled Tee'
)

SELECT item_name, SUM(quantity) AS total_quantity
FROM ITEM_QUANTITY
GROUP BY item_name
HAVING SUM(quantity) IS NOT NULL
ORDER BY total_quantity DESC
LIMIT 1;

  


  