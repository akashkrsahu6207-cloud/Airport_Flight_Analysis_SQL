## create database database_name 
create  database Flight_Analysis;

## use database -- main_dataset--
use flight_analysis;


select count(*) from airport_project_data;


-- change  the name of table airport_project_data to meta_data--
alter table airport_project_data rename to meta_data;
 
 ## new table_name -- meta_data
select * from meta_data;
select count(*) as number_of_rows from meta_data;

## now meta_data convert into various small table dataset
## airport , flight , route , passengers and city - small tables

-- create table Airline --
CREATE TABLE Airline (
    AIRLINE_ID INT PRIMARY KEY,
    UNIQUE_CARRIER VARCHAR(10),
    UNIQUE_CARRIER_NAME VARCHAR(100),
    UNIQUE_CARRIER_ENTITY VARCHAR(10)
);


-- create table Airport--
CREATE TABLE Airport (
    AIRPORT_ID INT PRIMARY KEY,
    AIRPORT_SEQ_ID INT,
    CITY_MARKET_ID INT,
    AIRPORT_CODE VARCHAR(10),
    CITY_NAME VARCHAR(100),
    STATE_ABR CHAR(2),
    STATE_FIPS INT,
    STATE_NM VARCHAR(100),
    WAC INT
);

-- create table Flight--
CREATE TABLE Flight (
    FLIGHT_ID INT AUTO_INCREMENT PRIMARY KEY,
    AIRLINE_ID INT,
    ORIGIN_AIRPORT_ID INT,
    DEST_AIRPORT_ID INT,
    DISTANCE FLOAT,
    DISTANCE_GROUP INT,
    YEAR INT,
    QUARTER INT,
    MONTH INT,
    CLASS CHAR(1),
    FOREIGN KEY (AIRLINE_ID) REFERENCES Airline(AIRLINE_ID),
    FOREIGN KEY (ORIGIN_AIRPORT_ID) REFERENCES Airport(AIRPORT_ID),
    FOREIGN KEY (DEST_AIRPORT_ID) REFERENCES Airport(AIRPORT_ID)
);

-- create table Flightmetrics--
CREATE TABLE FlightMetrics (
    FLIGHT_ID INT,
    PASSENGERS int,
    FREIGHT  float,
    MAIL int,
    FOREIGN KEY (FLIGHT_ID) REFERENCES Flight(FLIGHT_ID)
);
drop table flightmetrics;
-- create table city--
CREATE TABLE City (
	City_id INT  auto_increment primary KEY,
    City_Name VARCHAR(100),
    STATE_ABR CHAR(2),
	State_NM VARCHAR(100));
    

     
## Data Insertion

-- into Airline--
INSERT  ignore INTO Airline (AIRLINE_ID, UNIQUE_CARRIER, UNIQUE_CARRIER_NAME, UNIQUE_CARRIER_ENTITY)
SELECT DISTINCT
    AIRLINE_ID,
    UNIQUE_CARRIER,
    UNIQUE_CARRIER_NAME,
    UNIQUE_CARRIER_ENTITY
FROM Meta_Data
where airline_id is not null;

select * from airline;
select count(distinct(airline_id)) from airline;

     
-- insert into Airport--
-- origin airport--
INSERT  ignore INTO Airport (
    AIRPORT_ID, AIRPORT_SEQ_ID, CITY_MARKET_ID, AIRPORT_CODE,
    CITY_NAME, STATE_ABR, STATE_FIPS, STATE_NM, WAC
)
SELECT DISTINCT
    ORIGIN_AIRPORT_ID,
    ORIGIN_AIRPORT_SEQ_ID,
    ORIGIN_CITY_MARKET_ID,
    ORIGIN,
    ORIGIN_CITY_NAME,
    ORIGIN_STATE_ABR,
    ORIGIN_STATE_FIPS,
    ORIGIN_STATE_NM,
    ORIGIN_WAC
FROM Meta_Data

UNION
-- dest airport--
SELECT DISTINCT
    DEST_AIRPORT_ID,
    DEST_AIRPORT_SEQ_ID,
    DEST_CITY_MARKET_ID,
    DEST,
    DEST_CITY_NAME,
    DEST_STATE_ABR,
    DEST_STATE_FIPS,
    DEST_STATE_NM,
    DEST_WAC
FROM Meta_Data;

select * from airport;

-- insert into flight--
INSERT INTO Flight (
    AIRLINE_ID, ORIGIN_AIRPORT_ID, DEST_AIRPORT_ID,
    DISTANCE, DISTANCE_GROUP,
    YEAR, QUARTER, MONTH, CLASS
)
SELECT
    AIRLINE_ID,
    ORIGIN_AIRPORT_ID,
    DEST_AIRPORT_ID,
    DISTANCE,
    DISTANCE_GROUP,
    YEAR,
    QUARTER,
    MONTH,
    CLASS
FROM Meta_Data;

select * from flight;

-- insert into flightmetrics--
INSERT INTO FlightMetrics (
    FLIGHT_ID, PASSENGERS, FREIGHT, MAIL
)
SELECT
    f.FLIGHT_ID,
    m.PASSENGERS,
    

cast(nullif(m.FREIGHT,'') as decimal(12,2)),
m.MAIL
FROM Meta_Data m
JOIN Flight f
  ON f.AIRLINE_ID = m.AIRLINE_ID
 AND f.ORIGIN_AIRPORT_ID = m.ORIGIN_AIRPORT_ID
 AND f.DEST_AIRPORT_ID = m.DEST_AIRPORT_ID
 AND f.YEAR = m.YEAR
 AND f.MONTH = m.MONTH
 AND f.QUARTER = m.QUARTER
 where m.freight is not null;

 
 select * from meta_data;
 
 
 -- insert into city--
INSERT INTO City (City_Name, STATE_ABR, State_NM)
SELECT DISTINCT
ORIGIN_CITY_NAME,
ORIGIN_STATE_ABR,
ORIGIN_STATE_NM
FROM meta_data;
 
 select * from city;
 
INSERT INTO City (City_Name, STATE_ABR, State_NM)
SELECT DISTINCT
DEST_CITY_NAME,
DEST_STATE_ABR,
DEST_STATE_NM
FROM meta_data
where DEST_CITY_NAME NOT IN(
SELECT CITY_NAME FROM CITY);

SELECT * FROM CITY;

## reterive all the table 

select * from meta_data;
select * from airport;
select * from flight;
select * from airline;
select * from flightmetrics;
select * from city;



## DATA_ANALYSIS-----


## Route wise flight analysis

select 
f.origin_airport_id,
f.dest_airport_id,
a1.city_name as origin_city,
a1.city_name as dest_city,
sum(fm.passengers) as total_passenger
from flight as f
join flightmetrics as fm on f.flight_id = fm.flight_id 
join airport as a1 on f.ORIGIN_AIRPORT_ID = a1.AIRPORT_ID 
join airport as a2 on f.DEST_AIRPORT_ID = a2.AIRPORT_ID
group by f.ORIGIN_AIRPORT_ID,f.DEST_AIRPORT_ID
order by total_passenger desc
limit 10;


## total number of passengers served in the duration 

select 
f.year , f.month , round(sum(fm.passengers)/1000000,2) as Total_passengers_in_millions
from flight as f join flightmetrics as fm on f.flight_id = fm.flight_id
group by f.year , f.month
order by f.year , f.month;


##  Determine the average passengers per flight for various route and airport .

-- average passengers per origin city:-

select f.origin_airport_id , a.city_name as origin_city_name ,
count(f.flight_id) as total_flight,
sum(fm.passengers) as total_passengers,
round(avg(fm.passengers),2)as avg_passengers_per_flight
from
flight as f
join flightmetrics as fm on f.flight_id = fm.flight_id
join airport as a on f.ORIGIN_AIRPORT_ID = a.airport_id
group by f.ORIGIN_AIRPORT_ID
order by avg_passengers_per_flight  desc;


-- average passenger per destination city

select 
f.dest_airport_id , a.city_name as dest_city_name ,
count(f.flight_id) as total_flight,
sum(fm.passengers) as total_no_passenger,
round(avg(fm.passengers),2) as avg_passeners_per_flight
from
flight as f
join airport as a on a.AIRPORT_ID = f.DEST_AIRPORT_ID
join flightmetrics as fm on fm.flight_id = f.FLIGHT_ID
group by f.dest_airport_id , a.CITY_name 
order by avg_passeners_per_flight desc ;


## Top performing Airport using- total number of passengers and total number of flight's.

-- for origin airport_id and origin_city_name

select
      a.airport_id  , a.city_name as origin_city ,
      count(f.flight_id)as no_of_flight , 
      sum(fm.passengers) as no_of_passengers
      from flight as f
      join flightmetrics as fm on f.FLIGHT_ID = fm.FLIGHT_ID
      join airport as a on a.AIRPORT_ID = f.ORIGIN_AIRPORT_ID
      group by a.airport_id , a.city_name
	order by no_of_flight desc;
 
-- for destination airport_id and destination city_name 

select
      a.airport_id  , a.city_name as dest_city ,
      count(f.flight_id)as no_of_flight , 
      sum(fm.passengers) as no_of_passengers
      from flight as f
      join flightmetrics as fm on f.FLIGHT_ID = fm.FLIGHT_ID
      join airport as a on a.AIRPORT_ID = f.DEST_AIRPORT_ID
      group by a.airport_id , a.city_name
	order by no_of_flight desc;
    
    
    ## Flight Frequency between origin to dest 
    
    select f.origin_airport_id ,f.dest_airport_id,
    a1.city_name as origin_city_name , a2.city_name as dest_city_name ,
    count(*) as total_flight
    from flight as f 
    join airport as a1
    on f.ORIGIN_AIRPORT_ID = a1.AIRPORT_ID
    join airport as a2
    on f.dest_AIRPORT_ID = a2.AIRPORT_ID
    group by f.ORIGIN_AIRPORT_ID , f.DEST_AIRPORT_ID
    order by total_flight desc
    limit 5;
    
    

-- ADD NEW TABLE ALL_CITY_POP
-- RENAME THAT table  
 alter table all_city_pop rename to city_pop;
 
 select * from city;
 select * from city_pop;
 
 set sql_safe_updates =0; 
 update city set city_name = substring_index(city_name ,',',1);
 
 select * from city;
 
 create table city_new(select c.city_id , c.city_name , c.state_abr,c.state_nm, cp.population 
 from city as c join city_pop as cp
 on c.City_Name=cp.city_name);
 
 select * from city_new;
 
update airport set city_name = substring_index(city_name ,',',1);

select * from airport;
  

 
 
 
## Analyse the relation between city population and Air traffic 
-- origin city

select c.city_name , c.population , 
sum(fm.passengers) as total_passengers,
round(sum(fm.passengers)/c.population,2) as pass_pop_ratio
from city_new as c
join airport as a on c.city_name = a.city_name 
join flight as f on a.AIRPORT_ID = f.ORIGIN_AIRPORT_ID 
join flightmetrics as fm on f.FLIGHT_ID = fm.FLIGHT_ID
group by c.city_name , c.population
order by total_passengers desc;

-- destination city

select c.city_name , c.population , 
sum(fm.passengers) as total_passengers,
round(sum(fm.passengers)/c.population,2) as pass_pop_ratio
from city_new as c
join airport as a on c.city_name = a.city_name 
join flight as f on a.AIRPORT_ID = f.DEST_AIRPORT_ID 
join flightmetrics as fm on f.FLIGHT_ID = fm.FLIGHT_ID
group by c.city_name , c.population
order by total_passengers desc;











