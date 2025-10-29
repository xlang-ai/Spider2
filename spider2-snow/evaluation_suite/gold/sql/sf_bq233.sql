WITH python_files AS (
  SELECT 
    sf."path",
    sc."content",
    'Python' as language
  FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_FILES sf 
  JOIN GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS sc ON sf."id" = sc."id" 
  WHERE sc."binary" = FALSE 
  AND sf."path" ILIKE '%.py'
),
python_import_lines AS (
  SELECT 
    language,
    "path",
    TRIM(line.value) as line_content
  FROM python_files,
  LATERAL SPLIT_TO_TABLE("content", '\n') line
  WHERE TRIM(line.value) LIKE 'import %' 
     OR TRIM(line.value) LIKE 'from %import%'
),
parsed_python_imports AS (
  SELECT 
    language,
    CASE 
      -- Handle "import module" statements - extract first module name
      WHEN line_content LIKE 'import %' AND line_content NOT LIKE 'from %' THEN
        TRIM(SPLIT_PART(SPLIT_PART(line_content, 'import ', 2), ',', 1))
      -- Handle "from module import ..." statements - extract the main module
      WHEN line_content LIKE 'from %import%' THEN
        TRIM(SPLIT_PART(SPLIT_PART(line_content, 'from ', 2), ' import', 1))
      ELSE NULL
    END as full_module_name
  FROM python_import_lines
  WHERE line_content IS NOT NULL AND line_content != ''
),
python_base_modules AS (
  SELECT 
    language,
    -- Extract the base module name (first part before dot)
    SPLIT_PART(full_module_name, '.', 1) as module_name
  FROM parsed_python_imports
  WHERE full_module_name IS NOT NULL AND full_module_name != ''
),
python_results AS (
  SELECT 
    language,
    module_name,
    COUNT(*) as occurrence_count
  FROM python_base_modules
  WHERE module_name IS NOT NULL AND module_name != ''
  GROUP BY language, module_name
),
r_files AS (
  SELECT 
    "sample_path" as r_path,
    "content",
    'R' as language
  FROM GITHUB_REPOS.GITHUB_REPOS.SAMPLE_CONTENTS 
  WHERE "binary" = FALSE 
  AND ("sample_path" ILIKE '%.r' OR "sample_path" ILIKE '%.R' OR "sample_path" ILIKE '%.Rmd')
),
r_import_lines AS (
  SELECT 
    language,
    r_path,
    TRIM(line.value) as line_content
  FROM r_files,
  LATERAL SPLIT_TO_TABLE("content", '\n') line
  WHERE TRIM(line.value) LIKE 'library(%' 
     OR TRIM(line.value) LIKE 'require(%'
),
parsed_r_imports AS (
  SELECT 
    language,
    CASE 
      -- Handle library() statements
      WHEN line_content LIKE 'library(%' THEN
        TRIM(REPLACE(REPLACE(SPLIT_PART(SPLIT_PART(line_content, 'library(', 2), ')', 1), '"', ''), '\\', ''))
      -- Handle require() statements  
      WHEN line_content LIKE 'require(%' THEN
        TRIM(REPLACE(REPLACE(SPLIT_PART(SPLIT_PART(line_content, 'require(', 2), ')', 1), '"', ''), '\\', ''))
      ELSE NULL
    END as library_name
  FROM r_import_lines
  WHERE line_content IS NOT NULL AND line_content != ''
),
r_results AS (
  SELECT 
    language,
    library_name as module_name,
    COUNT(*) as occurrence_count
  FROM parsed_r_imports
  WHERE library_name IS NOT NULL AND library_name != ''
  GROUP BY language, library_name
),
combined_results AS (
  SELECT language, module_name, occurrence_count FROM python_results
  UNION ALL
  SELECT language, module_name, occurrence_count FROM r_results
)
SELECT 
  language,
  module_name,
  occurrence_count
FROM combined_results
ORDER BY language, occurrence_count DESC, module_name