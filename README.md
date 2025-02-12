![Case Study](https://github.com/user-attachments/assets/c0cf8c17-0fd0-4fb1-89ef-64327d32fdad)

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

With the dataset now cleaned, I decided to hop over to **Microsoft Power BI** to begin my analysis. I wanted to start by revisting my initial considerations about the data from when I first explored it. As a refresher:

> - Can calculate ride frequency & duration to see if there are any correlations with membership status.
> - Could look into a relationship between the bike type and membership status.
> - May want to assess the makeup of membership status across different stations.
> - Might be able to see if there are any correlations between membership and time of day the bikes are used.
> - Similarly, can explore day of week and seasonality for insights.

I imported the BigQuery dataset into Power BI to tackle these one at a time. I found the results illuminating! 

## Share

First, I took a look into trip frequency and duration:

![PBIDesktop_E8dAAmKlHi](https://github.com/user-attachments/assets/c7b226fd-a90c-48ce-8d43-ee9045efe897)

![PBIDesktop_DWOJf6osVC](https://github.com/user-attachments/assets/ccbe95b2-3ee2-49ff-a640-57bd89728336)

It's immediately clear that there's a sizable disparity here between frequency and duration. Members account for a large majority of the number of trips, but actually spent less time overall on the bikes than their casual counterparts.

![PBIDesktop_LFYQDR84EH](https://github.com/user-attachments/assets/df27e2d1-a0d7-4f18-b2fa-92a18dde3396)

We see further confirmation of this in the average trip duration. 

> **Conclusion #1: Casual riders tend to take longer trips on Cyclistic bikes than members.**

---

Next up, a look into the data relationships with different types of bike offerings:

![PBIDesktop_49uwFWKpXi](https://github.com/user-attachments/assets/9b633aa0-6767-44a0-b72e-1f2164bc39db)

It's clear that classic bikes are far and away the most used offering followed distantly by electric bikes, with electric scooters lagging even further behind. This relationship is less extreme in number of trips, but still holds.

![PBIDesktop_ovrvP24R5k](https://github.com/user-attachments/assets/c530af32-28a0-4102-9793-dfa516b9758a)

That overall usage is at least partially accounted for by the average trip duration of each offering. Classic bikes are taken out for longer while both electric offerings are used for short trips.

![PBIDesktop_WPaYgDHtt2](https://github.com/user-attachments/assets/e319cc0d-019c-40e8-8bec-2fbd58f29d00)

Here is where things get really interesting. Even though casual riders typically ride for longer than members and scooters are typically used for short trips, casual members seem to really like using them. They are the only option more popular with casual riders than with members.

> **Conclusion #2: Electric scooters are more popular with casual riders than with members; bikes are much more popular with members than with casual riders.**

---

I decided to next look into the geographic data. Using the coordinates available, I put together some heat maps for start and end locations:

![Map-Casual](https://github.com/user-attachments/assets/54ca5f3b-1934-4e5d-9007-9efc592c153f)

![Map-Member](https://github.com/user-attachments/assets/6bb950a3-0840-441e-a438-dfa2e3902116)

The differences here are fairly subtle. The majority of usage occurs in central Chicago with a second hotspot in uptown near Wrigley Field, but members do have a wider area of secondary usage further out in the suburbs and the south side. This seems to indicate that members may be using the rentals for travel to and from the city proper more often than casual riders.

> **Conclusion #3: Member bike usage is more geographically spread out than casual rider usage.**

---

Lastly, I wanted to look into the relationship between membership status and time; I charted bike usage over the course of a year, of a week, and of a day to see if anything would stand out.

First, an overall picture of usage by season:

![PBIDesktop_suuiNsmFMH](https://github.com/user-attachments/assets/d423fe5a-d1a0-444e-baee-1eeb7079ae1b)

Summer was by far the most popular season, which makes a lot of sense in a city like Chicago where the weather can be brutal in winter. I wanted to get a little more granular though, so I took a look at the data by month:

![PBIDesktop_K8sIMFKVEx](https://github.com/user-attachments/assets/2fa41b0e-a5d8-47c7-9cdd-704dc7ea34d3)

We see the same usage preference for the summer months here, but interestingly the effect is less pronounced for members than it is for casual riders. This suggests that member usage may be for more routine purposes that are less influenced by the weather, like a daily work commute. Drilling down into the weekly and daily data could help to clarify:

![PBIDesktop_5EYpkkuGyy](https://github.com/user-attachments/assets/3177043c-5e67-453e-aa04-74da514e4d39)

![PBIDesktop_fl3lKU3Qyc](https://github.com/user-attachments/assets/14c072a9-796b-4d2f-83b5-7c34c88267ef)

These charts were particularly striking. The weekly data very clearly shows that member usage is well spread out across the week while casual usage is extremely concentrated on the weekends. Further, the daily data shows clear spikes in member usage around the 8AM and 5PM hours, while casual usage is more evenly distributed throughout daylight hours. All of the above charts point towards the same final conclusion:

> **Conclusion #4: Members are more likely to use Cyclistic bikes for their daily commute. Casual riders use them more for recreation.**

---

### Summary of findings

| Casuals | Members |
| ------- | ------- |
| Typically take longer, more sporadic trips. | Typically take shorter, more routine trips. |
| Mostly ride bikes, but relatively more interest in scooters. | Greatly favor bikes, little interest in using scooters. |
| Mainly ride in the city proper. | Ride from and to the surrounding areas as well as within the city. |
| Primarily ride for recreation, over the weekends in the summer. | Primarily ride for commute, throughout the week and year. |

## Act:

Having identified several key differences between these two groups, I've put together three recommendations to help the company convert casual riders into members:

1. **Create a marketing campaign showcasing the benefits of bike-share for commuting.**

> Members seem to see a lot of value in using the service for their daily commute, so it makes sense to attempt to persuade casual riders that it might be a good option for them as well. For example, the company could highlight the benefits of ride-share availability, station access, and share success stories from existing members.

2. **Target casual riders where they are by offering membership perks for recreational usage.**

> As the above may not be an option for every casual rider, the company could also offer unique perks for their recreational customers as well. Partnering with local businesses to offer discounts on complementary services like ice cream shops or pizza places could be a good place to start.

3. **Offer a cheaper, but more limited membership option to increase the value of the membership for sporadic use.**

> It would be important to target this membership tier specifically towards casual riders as the company certainly wouldn't want existing members unneccessarily downgrading to a cheaper plan. Offering seasonal memberships for example sounds tempting but might be a bad idea as even regular members use the service less over winter. A better idea might be to offer weekend-only or scooter-only memberships. These options are less attractive to existing members but might prove popular with casual recreational riders.

---

I hope you find as much value in this case study as I did putting it together. Thank you for reading!

![bikes](https://github.com/user-attachments/assets/3ee80382-a6f8-42bb-96ea-60dea05e0ef4)
