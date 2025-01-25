# Case Study for Google Data Analytics: Cyclistic Bike Share

In this case study, I will use historical data from a bike-share company in Chicago, identifying trends in ridership in order to deliver actionable insights that will inform the company’s marketing strategy going forward.

## Scenario:

Cyclistic is a bike-share company started in 2016 that offers a large fleet of various bike offerings and stations across Chicago. They have two classes of typical customers: casual riders that use the bikes for single-rides or day passes and members that have purchased an annual membership.

The company has determined that they would like to convert more casual riders into members. Financial analysts have found that to be a more profitable segment that could drive future growth in the market, and the marketing director believes converting casual riders will be more fruitful than attracting new riders. 

With that goal in mind, it’s my department’s job to look into rider data and find insights to inform the company’s marketing strategy going forward. The primary stakeholders in this case are the director of marketing, my boss, as well as the rest of the executive team at the company.

The marketing team has been specifically tasked with answering three questions:

1. *How do annual members and casual riders use Cyclistic bikes differently?*
2. Why would casual riders buy Cyclistic annual memberships? 
3. How can Cyclistic use digital media to influence casual riders to become members?
   
For the scope of this case study, I am focused on just that first question. I will be looking into relevant data sets to identify patterns, develop profiles, and determine actionable insights that will help my team to come up with a marketing strategy to help convert more **casual riders** into **members**.

## Business Task:

> ### Identify how annual members and casual riders use Cyclistic bikes differently using historical ridership data.

## Data Source:

For this case study, I will be using bike trip data from January thru December 2024, publicly available [here](https://divvy-tripdata.s3.amazonaws.com/index.html). The data has been made available by Motivate International Inc. under [this license](https://www.divvybikes.com/data-license-agreement). 

The data is stored across 12 separate spreadsheets, one per month, titled the following:

```
202401-divvy-tripdata.zip
202402-divvy-tripdata.zip  
202403-divvy-tripdata.zip  
202404-divvy-tripdata.zip  
202405-divvy-tripdata.zip  
202406-divvy-tripdata.zip  
202407-divvy-tripdata.zip 
202408-divvy-tripdata.zip
202409-divvy-tripdata.zip
202410-divvy-tripdata.zip
202411-divvy-tripdata.zip
202412-divvy-tripdata.zip
```

Each spreadsheet contains a record of every trip taken that month (rows). There are 13 fields containing data for each trip (columns). They are as follows:

```
ride_id               	#Ride id – unique id
rideable_type         	#Bike type – classic or electric
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

### Setup

Initially using Microsoft Excel, I was able to get a cursory glance at the data in the .CSV files. I filtered the data to get an idea of what the fields contained, types of data stored, how much data was missing, and other general information. 

I quickly realized that the combined size of the data set would be well over a million rows, beyond the scope of a spreadsheet project, so at this point I decided to switch to **SQL**.

I uploaded all 12 csv files to **BigQuery** via Google Cloud as tables in a dataset labeled `‘2024_bikedata’`. 

### Exploration

[Using this SQL Query](https://github.com/Geno2K/case-study-cyclistic/blob/main/table_setup.sql), I created a single table labeled `‘combined_data’`, containing a total of 5,860,568 rows of data, a record of every recorded trip taken in 2024.

> #### 5,860,568 total trips

```
SELECT column_name, data_type
FROM `2024_bikedata`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'combined_data';
```
> ![brave_dBtxBkOqP2](https://github.com/user-attachments/assets/114317c6-1138-4643-9518-1146ebb5eb66)

These were the data_types represented in the table.


```
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

There were no missing values for many of the fields, but stations and ending coordinates had many missing values.

```
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

There were duplicate values in every column. Some of these make sense (there are only a few value options available), but the one that caught my eye was ride_id, which should have been unique. I noted this for cleaning later.


### Cleaning

```
-- Common Table Expression (CTE) to rank rows based on 'Name'
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ride_id) AS RowNum
    FROM `2024_bikedata.combined_data`
)
-- Select only the unique records where RowNum = 1
SELECT *
FROM CTE
WHERE RowNum = 1;
```
Returns a table with duplicate ride_id entries removed.
