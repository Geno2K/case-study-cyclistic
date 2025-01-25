DROP TABLE IF EXISTS `2024_bikedata.combined_data`;

CREATE TABLE IF NOT EXISTS `2024_bikedata.combined_data` AS (
  SELECT * FROM `2024_bikedata.01_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.02_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.03_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.04_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.05_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.06_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.07_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.08_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.09_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.10_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.11_bikedata`
  UNION ALL
  SELECT * FROM `2024_bikedata.12_bikedata`
);

SELECT COUNT(*)
FROM `2024_bikedata.combined_data`;