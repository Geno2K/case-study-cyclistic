# Case Study for Google Data Analytics: Cyclistic Bike Share

In this case study, I will analyze historical data from a bike-share company in Chicago, identifying trends in ridership in order to deliver actionable insights that will inform the company’s marketing strategy going forward.

## Scenario:

Cyclistic is a bike-share company started in 2016 that offers a large fleet of bikes with stations across Chicago. The company has two classes of customers: 

- Casual riders that use the bikes for single-rides or day passes.
- Members that have purchased an annual subscription.

The company's financial analysts have determined that the membership program is a more profitable segment capable of driving future growth in the market, and is therefore seeking ways to expand it. The company's marketing director believes it will be easier to convert casual riders into members than attract new customers directly. 

With that goal in mind, it’s my department’s job to look into the rider data and seek out insights to inform the company’s marketing strategy going forward. The primary stakeholders in this case are the director of marketing as well as the rest of the executive team at the company.

The marketing team has been specifically tasked with answering three questions:

1. *How do annual members and casual riders use Cyclistic bikes differently?*
2. Why would casual riders buy Cyclistic annual memberships? 
3. How can Cyclistic use digital media to influence casual riders to become members?
   
For the scope of this case study, I am focused on just that first question. I will be looking into relevant data sets to identify patterns, develop profiles, and determine actionable insights that will help my team devise a marketing strategy to convert more **casual riders** into **members**.

## Business Task:

> ### Identify how annual members and casual riders use Cyclistic bikes differently using historical ridership data.

## Data Source:

For this case study, I will be using bike trip data from January thru December 2024, publicly accessible [here](https://divvy-tripdata.s3.amazonaws.com/index.html). The data has been made available by Motivate International Inc. under [this license](https://www.divvybikes.com/data-license-agreement). 

The data is stored across 12 separate spreadsheets, one per month, titled the following:

```
-- Files

202401-divvy-tripdata.csv
202402-divvy-tripdata.csv  
202403-divvy-tripdata.csv  
202404-divvy-tripdata.csv  
202405-divvy-tripdata.csv  
202406-divvy-tripdata.csv  
202407-divvy-tripdata.csv 
202408-divvy-tripdata.csv
202409-divvy-tripdata.csv
202410-divvy-tripdata.csv
202411-divvy-tripdata.csv
202412-divvy-tripdata.csv
```

Each spreadsheet contains a record of every trip taken that month (rows). For each trip, there are 13 fields containing specific data (columns). They are as follows:

```
-- Fields

ride_id               	#Ride id – unique id
rideable_type         	#Bike type – classic, electric, scooter
started_at            	#Trip start day and time
ended_at              	#Trip end day and time
start_station_name      #Trip start station
start_station_id      	#Trip start station id
end_station_name        #Trip end station
end_station_id        	#Trip end station id
start_lat             	#Trip start latitude  
start_lng             	#Trip start longitude   
end_lat               	#Trip end latitude  
end_lat               	#Trip end longitude   
member_casual         	#Status - Member or Casual  
```
The data is reliable, original, comprehensive, current, and cited (ROCCC).  It contains an up-to-date record of last year’s ridership data for Cyclistic that is both accurate and complete. The dataset was provided specifically for this case study and is publicly available and licensed. 
Notably, this dataset contains information about the _membership status_ of the rider for each trip, which will be critical for determining the differences in use between casual riders and members.

## Data Processing:

Before going any further, I took some initial observations of the data and considered how it could be used to accomplish my task:

#### Initial considerations
> - Can calculate ride duration for each trip to see if there are any correlations with membership status.
> - Could look into a relationship between the bike type and membership status.
> - May want to assess the makeup of membership status across different stations.
> - Might be able to see if there are any correlations between membership and time of day the bikes are used.
> - Similarly, can explore day of week and seasonality for insights.

It was clear the dataset had a lot of interesting insights that could be gleaned from it, but I'd need to do a little prep work first.

### Setup
---
I initially used Microsoft Excel, filtering the data to get an idea of what the fields contained, types of data stored, if data was missing, and other general information about the spreadsheets.  

I quickly realized that the combined size of the data set would be over a million rows though, well beyond the scope of a spreadsheet analysis project, so I switched over to **SQL** to proceed with the case study.

I uploaded all 12 csv files to **BigQuery** via Google Cloud as tables in a dataset labeled `‘2024_bikedata’`.  Using [this SQL Query](https://github.com/Geno2K/case-study-cyclistic/blob/main/table_setup.sql), I created a single table labeled `‘combined_data’`, containing a total of 5,860,568 rows of data, a record of every recorded trip taken in 2024.

### Exploration
---
With the dataset uploaded and combined into a single table, I began to write some queries to explore it and prepare it for analysis.
```
-- List of data types

SELECT column_name, data_type
FROM `2024_bikedata`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'combined_data';
```
> ![brave_dBtxBkOqP2](https://github.com/user-attachments/assets/114317c6-1138-4643-9518-1146ebb5eb66)

These were the data_types represented in the table.

---

```
-- Check for missing values

SELECT COUNT(*) - COUNT(ride_id) ride_id,
 COUNT(*) - COUNT(rideable_type) rideable_type,
 COUNT(*) - COUNT(started_at) started_at,
 COUNT(*) - COUNT(ended_at) ended_at,
 COUNT(*) - COUNT(start_station_name) start_station_name,
 COUNT(*) - COUNT(start_station_id) start_station_id,
 COUNT(*) - COUNT(end_station_name) end_station_name,
 COUNT(*) - COUNT(end_station_id) end_station_id,
 COUNT(*) - COUNT(start_lat) start_lat,
 COUNT(*) - COUNT(start_lng) start_lng,
 COUNT(*) - COUNT(end_lat) end_lat,
 COUNT(*) - COUNT(end_lng) end_lng,
 COUNT(*) - COUNT(member_casual) member_casual
 FROM `2024_bikedata.combined_data`;
```
> ![brave_9l9WoGyyLW](https://github.com/user-attachments/assets/ed69d67a-1250-43cf-83fb-618ca9be5e9b)

There were no missing values for most of the fields, but stations and ending coordinates had many missing values.

---

```
-- Check for duplicate entries

SELECT COUNT(ride_id) - COUNT(distinct ride_id) ride_id,
 COUNT(rideable_type) - COUNT(distinct rideable_type) rideable_type,
 COUNT(started_at) - COUNT(distinct started_at) started_at,
 COUNT(ended_at) - COUNT(distinct ended_at) ended_at,
 COUNT(start_station_name) - COUNT(distinct start_station_name) start_station_name,
 COUNT(start_station_id) - COUNT(distinct start_station_id) start_station_id,
 COUNT(end_station_name) - COUNT(distinct end_station_name) end_station_name,
 COUNT(end_station_id) - COUNT(distinct end_station_id) end_station_id,
 COUNT(start_lat) - COUNT(distinct start_lat) start_lat,
 COUNT(start_lng) - COUNT(distinct start_lng) start_lng,
 COUNT(end_lat) - COUNT(distinct end_lat) end_lat,
 COUNT(end_lng) - COUNT(distinct end_lng) end_lng,
 COUNT(member_casual) - COUNT(distinct member_casual) member_casual
 FROM `2024_bikedata.combined_data`;
```
> ![brave_LqkZxL8LYg](https://github.com/user-attachments/assets/5f8803cb-bafd-455e-ae08-be95c0cfe346)

There were duplicate values in every column. Some of these make sense (there are only a few bike types available, for instance), but ride_id should have been unique. 

---

```
--Check membership status options

SELECT DISTINCT member_casual, COUNT(member_casual) AS no_of_trips
FROM `2024_bikedata.combined_data`
GROUP BY member_casual;
```
> ![brave_lFnqYQAwYV](https://github.com/user-attachments/assets/cd6bae3d-9080-4345-b863-c08e08c1b387)

Only two classes of membership, casual or member. Nothing unexpected there.

---

```
-- Check bike type options

SELECT DISTINCT rideable_type, COUNT(rideable_type) AS no_of_trips
FROM `2024_bikedata.combined_data`
GROUP BY rideable_type;
```
> ![brave_cpsnb3bsC7](https://github.com/user-attachments/assets/51b16cb8-7008-41dc-9a1f-a98921fed64e)

Three types of offerings: bikes, electric bikes, and electric scooters. Electric bikes and classic bikes were much more common than scooters.

---

```
-- Check ride_id lengths

SELECT LENGTH(ride_id) AS length_ride_id, COUNT(ride_id) AS no_of_rows
FROM `2024_bikedata.combined_data`
GROUP BY length_ride_id;
```
> ![brave_CBQPBZLTtt](https://github.com/user-attachments/assets/8b8560cb-058d-4b6d-a453-d1763525bf4f)

Mostly 16 digit ride_ids, but a handful of other lengths that needed to be cleaned.

---

```
-- Check for trips with ending times earlier than starting times

SELECT COUNT(*) AS negative_rides
FROM `2024_bikedata.combined_data`
WHERE (
  EXTRACT(HOUR FROM (ended_at - started_at)) * 60 +
  EXTRACT(MINUTE FROM (ended_at - started_at)) +
  EXTRACT(SECOND FROM (ended_at - started_at)) / 60) <= 0;
```
> ![brave_Iix8n41uyi](https://github.com/user-attachments/assets/e2dfe325-b5e5-4b15-8887-d4af81ba97a9)

These trips have starting times later than their ending times, which isn't possible. Will need to be cleaned.

---

```
-- Check for rides under a minute or over a day

SELECT COUNT(*) AS less_than_a_minute
FROM `2024_bikedata.combined_data`
WHERE (
  EXTRACT(HOUR FROM (ended_at - started_at)) * 60 +
  EXTRACT(MINUTE FROM (ended_at - started_at)) +
  EXTRACT(SECOND FROM (ended_at - started_at)) / 60) BETWEEN 0 AND 1;

SELECT COUNT(*) AS more_than_a_day
FROM `2024_bikedata.combined_data`
WHERE (
  EXTRACT(HOUR FROM (ended_at - started_at)) * 60 +
  EXTRACT(MINUTE FROM (ended_at - started_at)) +
  EXTRACT(SECOND FROM (ended_at - started_at)) / 60) >= 1440;
```
> ![brave_doStAKjIOA](https://github.com/user-attachments/assets/7bacce68-c9bd-4a08-8abf-619f80ea30f6)
> ![brave_iTRAQjO8rp](https://github.com/user-attachments/assets/8c2a822d-f15d-461c-b25f-402e71cdcfb4)

I decided that any trip lasting under a minute or over a day was implausible, or certainly outside of normal usage worth consideration, so these entries will need to be removed as well.

### Cleaning

Using what I discovered exploring the data, I put together the following query to clean up the data and return a new table that I could use to begin analysis proper.

#### [Data Cleaning SQL Query](https://github.com/Geno2K/case-study-cyclistic/blob/main/cleaning.sql)

> - Investigating the missing data was beyond the scope of this case study so for the purposes of continuing this analysis, all of those rows were removed, as were rows with duplicate ride_ids, incorrect ride_id syntax, and implausible trip durations.
> - Some new columns were also created to facilitate analysis: trip_duration, day_of_week, month, and season.
> - Number of removed rows was 1,695,592, leaving a new total of 4,164,976 rows in our cleaned table.

## Data Analysis:

Before hopping into visualizations, I decided to run some basic queries to check on those relationships I was curious about during my initial observations. Specifically, I wanted to see the relationships between membership status and each of the following:
- Total Rides
- Bike Type
- Ride Duration
- Time of Day
- Day of Week
- Season
- Starting/Ending Station

I compiled all my analysis queries into the following:
> [Data Analysis SQL Query]()
>
> -remove this just go straight to power bi

The raw results were illuminating, so I decided to move over to **Microsoft Power BI** to iterate further and put together visualizations from the results.

## Share

After importing my dataset into Power BI, I was able to use it to create some visualizations of the results of my analysis.
