WITH RECURSIVE char_split(word, char, rest, sorted) AS (
  SELECT
    words AS word,
    SUBSTR(words, 1, 1) AS char,
    SUBSTR(words, 2) AS rest,
    '' AS sorted
  FROM word_list
  UNION ALL
  SELECT
    word,
    SUBSTR(rest, 1, 1),
    SUBSTR(rest, 2),
    sorted || char
  FROM char_split
  WHERE rest <> ''
),
sorted_words AS (
  SELECT
    word,
    GROUP_CONCAT(char, '') AS sorted
  FROM (
    SELECT
      word,
      char
    FROM char_split
    ORDER BY word, char
  )
  GROUP BY word
),
get_anagram AS (
  SELECT 
    s1.word AS word,
    CASE
      -- Only check words of the same length.
      WHEN LENGTH(s1.sorted) = LENGTH(s2.sorted) THEN
        CASE
          -- If sorted words are the same, they contain the same letters and are anagrams
          WHEN s1.sorted = s2.sorted THEN s2.word
          ELSE NULL
        END
    END AS anagram
  FROM sorted_words AS s1
  JOIN sorted_words AS s2
  ON s1.word <> s2.word
)
SELECT
  word,
  COUNT(anagram) AS anagram_count
FROM
  get_anagram
WHERE 
  anagram IS NOT NULL
AND 
  LENGTH(word) > 3
AND 
  LENGTH(word) <= 5
AND 
  word LIKE 'r%'
GROUP BY 
  word
ORDER BY 
  word
LIMIT 10;