WITH data AS (
  SELECT
    EXTRACT(YEAR FROM wx.date) AS year,
    MAX(IF(wx.element = 'PRCP', wx.value/10, NULL)) AS max_prcp,
    MAX(IF(wx.element = 'TMIN', wx.value/10, NULL)) AS max_tmin,
    MAX(IF(wx.element = 'TMAX', wx.value/10, NULL)) AS max_tmax
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_2013` AS wx
  WHERE
    wx.id = 'USW00094846' AND
    wx.qflag IS NULL AND
    wx.value IS NOT NULL AND
    DATE_DIFF(DATE('2013-12-31'), wx.date, DAY) < 15
  GROUP BY
    year

  UNION ALL

  SELECT
    EXTRACT(YEAR FROM wx.date) AS year,
    MAX(IF(wx.element = 'PRCP', wx.value/10, NULL)) AS max_prcp,
    MAX(IF(wx.element = 'TMIN', wx.value/10, NULL)) AS max_tmin,
    MAX(IF(wx.element = 'TMAX', wx.value/10, NULL)) AS max_tmax
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_2014` AS wx
  WHERE
    wx.id = 'USW00094846' AND
    wx.qflag IS NULL AND
    wx.value IS NOT NULL AND
    DATE_DIFF(DATE('2014-12-31'), wx.date, DAY) < 15
  GROUP BY
    year

  UNION ALL

  SELECT
    EXTRACT(YEAR FROM wx.date) AS year,
    MAX(IF(wx.element = 'PRCP', wx.value/10, NULL)) AS max_prcp,
    MAX(IF(wx.element = 'TMIN', wx.value/10, NULL)) AS max_tmin,
    MAX(IF(wx.element = 'TMAX', wx.value/10, NULL)) AS max_tmax
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_2015` AS wx
  WHERE
    wx.id = 'USW00094846' AND
    wx.qflag IS NULL AND
    wx.value IS NOT NULL AND
    DATE_DIFF(DATE('2015-12-31'), wx.date, DAY) < 15
  GROUP BY
    year

  UNION ALL

  SELECT
    EXTRACT(YEAR FROM wx.date) AS year,
    MAX(IF(wx.element = 'PRCP', wx.value/10, NULL)) AS max_prcp,
    MAX(IF(wx.element = 'TMIN', wx.value/10, NULL)) AS max_tmin,
    MAX(IF(wx.element = 'TMAX', wx.value/10, NULL)) AS max_tmax
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_2016` AS wx
  WHERE
    wx.id = 'USW00094846' AND
    wx.qflag IS NULL AND
    wx.value IS NOT NULL AND
    DATE_DIFF(DATE('2016-12-31'), wx.date, DAY) < 15
  GROUP BY
    year
)

SELECT
  year,
  MAX(max_prcp) AS annual_max_prcp,
  MAX(max_tmin) AS annual_max_tmin,
  MAX(max_tmax) AS annual_max_tmax
FROM data
GROUP BY year
ORDER BY year ASC;
