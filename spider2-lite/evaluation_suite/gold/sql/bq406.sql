CREATE TEMP FUNCTION GrowthRate(end_value FLOAT64, begin_value FLOAT64)
RETURNS FLOAT64
AS ((end_value - begin_value) / begin_value);

SELECT
  GrowthRate(SUM(IF(report_year=2024, race_asian, 0)),
             SUM(IF(report_year=2014, race_asian, 0))) AS race_asian_growth,
  GrowthRate(SUM(IF(report_year=2024, race_black, 0)),
             SUM(IF(report_year=2014, race_black, 0))) AS race_black_growth,
  GrowthRate(SUM(IF(report_year=2024, race_hispanic_latinx, 0)),
             SUM(IF(report_year=2014, race_hispanic_latinx, 0))) AS race_hispanic_growth,
  GrowthRate(SUM(IF(report_year=2024, race_native_american, 0)),
             SUM(IF(report_year=2014, race_native_american, 0))) AS race_native_american_growth,
  GrowthRate(SUM(IF(report_year=2024, race_white, 0)),
             SUM(IF(report_year=2014, race_white, 0))) AS race_white_growth,
  GrowthRate(SUM(IF(report_year=2024, gender_us_women, 0)),
             SUM(IF(report_year=2014, gender_us_women, 0))) AS gender_us_women_growth,
  GrowthRate(SUM(IF(report_year=2024, gender_us_men, 0)),
             SUM(IF(report_year=2014, gender_us_men, 0))) AS gender_us_men_growth,
  GrowthRate(SUM(IF(report_year=2024, gender_global_women, 0)),
             SUM(IF(report_year=2014, gender_global_women, 0))) AS gender_global_women_growth,
  GrowthRate(SUM(IF(report_year=2024, gender_global_men, 0)),
             SUM(IF(report_year=2014, gender_global_men, 0))) AS gender_global_men_growth
FROM `bigquery-public-data.google_dei.dar_non_intersectional_representation`
WHERE report_year IN (2014, 2024)
  AND workforce = 'overall';