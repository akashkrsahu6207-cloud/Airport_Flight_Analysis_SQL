use flight_analysis;

create view route_analysis as 
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


create view passen_served_duration as select 
f.year , f.month , round(sum(fm.passengers)/1000000,2) as Total_passengers_in_millions
from flight as f join flightmetrics as fm on f.flight_id = fm.flight_id
group by f.year , f.month
order by f.year , f.month;




create view avg_pass_on_origin_city as select f.origin_airport_id , a.city_name as origin_city_name ,
count(f.flight_id) as total_flight,
sum(fm.passengers) as total_passengers,
round(avg(fm.passengers),2)as avg_passengers_per_flight
from
flight as f
join flightmetrics as fm on f.flight_id = fm.flight_id
join airport as a on f.ORIGIN_AIRPORT_ID = a.airport_id
group by f.ORIGIN_AIRPORT_ID
order by avg_passengers_per_flight  desc;



create view avg_pass_on_dest_city as select 
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


create view top_performing_airport_origin as select
      a.airport_id  , a.city_name as origin_city ,
      count(f.flight_id)as no_of_flight , 
      sum(fm.passengers) as no_of_passengers
      from flight as f
      join flightmetrics as fm on f.FLIGHT_ID = fm.FLIGHT_ID
      join airport as a on a.AIRPORT_ID = f.ORIGIN_AIRPORT_ID
      group by a.airport_id , a.city_name
	order by no_of_flight desc;
    
    
    
    create  view top_performing_airport_dest as select
      a.airport_id  , a.city_name as dest_city ,
      count(f.flight_id)as no_of_flight , 
      sum(fm.passengers) as no_of_passengers
      from flight as f
      join flightmetrics as fm on f.FLIGHT_ID = fm.FLIGHT_ID
      join airport as a on a.AIRPORT_ID = f.DEST_AIRPORT_ID
      group by a.airport_id , a.city_name
	order by no_of_flight desc;
    
    
    
    create view fligh_freq as select f.origin_airport_id ,f.dest_airport_id,
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
    
    
    
    create view pass_pop_origin as select c.city_name , c.population , 
sum(fm.passengers) as total_passengers,
round(sum(fm.passengers)/c.population,2) as pass_pop_ratio
from city_new as c
join airport as a on c.city_name = a.city_name 
join flight as f on a.AIRPORT_ID = f.ORIGIN_AIRPORT_ID 
join flightmetrics as fm on f.FLIGHT_ID = fm.FLIGHT_ID
group by c.city_name , c.population
order by total_passengers desc;



create view pass_pop_dest as 
select c.city_name , c.population , 
sum(fm.passengers) as total_passengers,
round(sum(fm.passengers)/c.population,2) as pass_pop_ratio
from city_new as c
join airport as a on c.city_name = a.city_name 
join flight as f on a.AIRPORT_ID = f.DEST_AIRPORT_ID 
join flightmetrics as fm on f.FLIGHT_ID = fm.FLIGHT_ID
group by c.city_name , c.population
order by total_passengers desc;


