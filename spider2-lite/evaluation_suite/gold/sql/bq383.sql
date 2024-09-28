SELECT
  REPLACE(date, "-", "") AS date,
  MAX(prcp) AS prcp,
  MAX(tmin) AS tmin,
  MAX(tmax) AS tmax
FROM (
  SELECT
    STRING(wx.date) AS date,
    IF(wx.element = 'PRCP', wx.value/10, NULL) AS prcp,
    IF(wx.element = 'TMIN', wx.value/10, NULL) AS tmin,
    IF(wx.element = 'TMAX', wx.value/10, NULL) AS tmax
  FROM
    `bigquery-public-data.ghcn_d.ghcnd_2016` AS wx
  WHERE
    id = 'USW00094846'
    AND qflag IS NULL
    AND value IS NOT NULL
    AND DATE_DIFF(DATE('2016-12-31'), wx.date, DAY) < 15
)
GROUP BY
  date
ORDER BY
  date ASC