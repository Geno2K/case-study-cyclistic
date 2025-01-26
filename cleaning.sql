-- Data Cleaning

DROP TABLE IF EXISTS `2024_bikedata.cleaned_combined_data`;

CREATE TABLE IF NOT EXISTS `2024_bikedata.cleaned_combined_data` AS (
  WITH ranked_data AS (
    SELECT 
      a.ride_id, 
      a.rideable_type, 
      a.started_at, 
      a.ended_at, 
      b.trip_duration,
      a.start_station_name, 
      a.end_station_name, 
      a.start_lat, 
      a.start_lng, 
      a.end_lat, 
      a.end_lng, 
      a.member_casual,
      ROW_NUMBER() OVER (PARTITION BY a.ride_id ORDER BY a.started_at) AS row_num,
      CASE EXTRACT(DAYOFWEEK FROM a.started_at) 
        WHEN 1 THEN 'SUN'
        WHEN 2 THEN 'MON'
        WHEN 3 THEN 'TUES'
        WHEN 4 THEN 'WED'
        WHEN 5 THEN 'THURS'
        WHEN 6 THEN 'FRI'
        WHEN 7 THEN 'SAT'    
      END AS day_of_week,
      CASE EXTRACT(MONTH FROM started_at)
        WHEN 1 THEN 'JAN'
        WHEN 2 THEN 'FEB'
        WHEN 3 THEN 'MAR'
        WHEN 4 THEN 'APR'
        WHEN 5 THEN 'MAY'
        WHEN 6 THEN 'JUN'
        WHEN 7 THEN 'JUL'
        WHEN 8 THEN 'AUG'
        WHEN 9 THEN 'SEP'
        WHEN 10 THEN 'OCT'
        WHEN 11 THEN 'NOV'
        WHEN 12 THEN 'DEC'
      END AS month,
      CASE
          WHEN (DATE(a.started_at) >= DATE(FORMAT_TIMESTAMP('%Y-03-19', a.started_at))
                AND DATE(a.started_at) < DATE(FORMAT_TIMESTAMP('%Y-06-20', a.started_at))) THEN 'Spring'
          WHEN (DATE(a.started_at) >= DATE(FORMAT_TIMESTAMP('%Y-06-20', a.started_at))
                AND DATE(a.started_at) < DATE(FORMAT_TIMESTAMP('%Y-09-22', a.started_at))) THEN 'Summer'
          WHEN (DATE(a.started_at) >= DATE(FORMAT_TIMESTAMP('%Y-09-22', a.started_at))
                AND DATE(a.started_at) < DATE(FORMAT_TIMESTAMP('%Y-12-21', a.started_at))) THEN 'Fall'
          ELSE 'Winter'
      END AS season
    FROM `2024_bikedata.combined_data` a
    JOIN (
      SELECT 
        ride_id, 
        ROUND((EXTRACT(HOUR FROM (ended_at - started_at)) * 60 +
         EXTRACT(MINUTE FROM (ended_at - started_at)) +
         EXTRACT(SECOND FROM (ended_at - started_at)) / 60), 0) AS trip_duration
      FROM `2024_bikedata.combined_data`
    ) b 
    ON a.ride_id = b.ride_id
    WHERE 
      a.start_station_name IS NOT NULL AND
      a.end_station_name IS NOT NULL AND
      a.end_lat IS NOT NULL AND
      a.end_lng IS NOT NULL AND
      b.trip_duration > 1 AND b.trip_duration < 1440 AND
      LENGTH(a.ride_id) = 16 -- Ensures ride_id is 16 digits
  )
  SELECT * EXCEPT(row_num)
  FROM ranked_data
  WHERE row_num = 1 -- Keeps only the first row for each duplicate ride_id
);

-- Sets ride_id as primary key

ALTER TABLE `2024_bikedata.cleaned_combined_data`     
ADD PRIMARY KEY(ride_id) NOT ENFORCED;

-- Returns updated row count

SELECT COUNT(ride_id) AS no_of_rows       
FROM `2024_bikedata.cleaned_combined_data`;
