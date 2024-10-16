WITH languages AS (
  SELECT
    files.id,
    CASE REGEXP_EXTRACT(files.path, r'(\.?[^\/\.]*)$')
      WHEN '.js'          THEN 'JavaScript'
      WHEN '.cjs'         THEN 'JavaScript'
      WHEN '.ts'          THEN 'TypeScript'
      WHEN '.java'        THEN 'Java'
      WHEN '.py'          THEN 'Python'
      WHEN '.kt'          THEN 'Kotlin'
      WHEN '.ktm'         THEN 'Kotlin'
      WHEN '.kts'         THEN 'Kotlin'
      WHEN '.c'           THEN 'C'
      WHEN '.h'           THEN 'C'
      WHEN '.c++'         THEN 'C++'
      WHEN '.cpp'         THEN 'C++'
      WHEN '.h++'         THEN 'C++'
      WHEN '.hpp'         THEN 'C++'
      WHEN '.cs'          THEN 'C#'
      WHEN '.erl'         THEN 'Erlang'
      WHEN '.ex'          THEN 'Elixir'
      WHEN '.exs'         THEN 'Elixir'
      WHEN '.hs'          THEN 'Haskell'
      WHEN '.go'          THEN 'Go'
      WHEN '.php'         THEN 'PHP'
      WHEN '.rb'          THEN 'Ruby'
      WHEN '.rs'          THEN 'Rust'
      WHEN '.scala'       THEN 'Scala'
      WHEN '.swift'       THEN 'Swift'
      WHEN '.lisp'        THEN 'Common Lisp'
      WHEN '.clj'         THEN 'Clojure'
      WHEN '.r'           THEN 'R'
      WHEN '.matlab'      THEN 'MATLAB'
      WHEN '.m'           THEN 'MATLAB'
      WHEN '.asm'         THEN 'Assembly'
      WHEN '.nasm'        THEN 'Assembly'
      WHEN '.d'           THEN 'D'
      WHEN '.dart'        THEN 'Dart'
      WHEN '.jl'          THEN 'Julia'
      WHEN '.groovy'      THEN 'Groovy'
      WHEN '.hx'          THEN 'Haxe'
      WHEN '.lua'         THEN 'Lua'
      WHEN '.sh'          THEN 'Shell'
      WHEN '.bash'        THEN 'Shell'
      WHEN '.ps1'         THEN 'PowerShell'
      WHEN '.psd1'        THEN 'PowerShell'
      WHEN '.psm1'        THEN 'PowerShell'
      WHEN '.sql'         THEN 'SQL'
      WHEN 'Dockerfile'   THEN 'Dockerfile'
      WHEN '.dockerfile'  THEN 'Dockerfile'
      WHEN '.md'          THEN 'Markdown'
      WHEN '.markdown'    THEN 'Markdown'
      WHEN '.mdown'       THEN 'Markdown'
      WHEN '.html'        THEN 'HTML'
      WHEN '.htm'         THEN 'HTML'
      WHEN '.css'         THEN 'CSS'
      WHEN '.sass'        THEN 'Sass'
      WHEN '.scss'        THEN 'SCSS'
      WHEN '.vue'         THEN 'Vue'
      WHEN '.json'        THEN 'JSON'
      WHEN '.yml'         THEN 'YAML'
      WHEN '.yaml'        THEN 'YAML'
      WHEN '.xml'         THEN 'XML'
    END AS language
  FROM
    `spider2-public-data.github_repos.sample_files` AS files
)

SELECT
  languages.language
FROM
  languages
INNER JOIN
  `spider2-public-data.github_repos.sample_contents` AS contents
ON
  contents.id = languages.id
WHERE
  languages.language IS NOT NULL
  AND contents.content IS NOT NULL
GROUP BY languages.language
ORDER BY COUNT(*) DESC
LIMIT 10;