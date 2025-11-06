create database Store_sales;
use store_sales;

-- part 1
-- create table 

create table sales
(
transaction_id varchar(30),	
customer_id	varchar(30),
customer_name varchar(30),
customer_age int null,	
gender varchar(30),	
product_id varchar(30),	
product_name varchar(30),	
product_category varchar(30),	
quantiy int,
prce int,	
payment_mode varchar(30),	
purchase_date date,	
time_of_purchase time,	
status varchar(30)
);
drop table sales;
select * from sales;

-- Part 2
-- insert records in table

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads( sales_store.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@transaction_id, @customer_id, @customer_name, @customer_age, @gender,
 @product_id, @product_name, @product_category, @quantity, @price,
 @payment_mode, @purchase_date, @time_of_purchase, @status)
SET
transaction_id   = NULLIF(@transaction_id, ''),
customer_id      = NULLIF(@customer_id, ''),
customer_name    = NULLIF(@customer_name, ''),
customer_age     = CASE WHEN @customer_age = '' THEN NULL ELSE @customer_age END,
gender           = NULLIF(@gender, ''),
product_id       = NULLIF(@product_id, ''),
product_name     = NULLIF(@product_name, ''),
product_category = NULLIF(@product_category, ''),
quantiy          = CASE WHEN @quantity = '' THEN NULL ELSE @quantity END,
prce             = CASE WHEN @price = '' THEN NULL ELSE @price END,
payment_mode     = NULLIF(@payment_mode, ''),
purchase_date    = CASE 
                     WHEN @purchase_date = '' THEN NULL 
                     ELSE STR_TO_DATE(TRIM(@purchase_date), '%d/%m/%Y') 
                   END,
time_of_purchase = NULLIF(@time_of_purchase, ''),
status           = NULLIF(@status, '');

select * from sales;
drop table salesdata;
create table salesdata as select * from sales;

-- Part 3
-- Data Cleaning

-- Step 1
-- To Check for duplicates

select * from salesdata;

select transaction_id, count(*) from salesdata
group by transaction_id
having count(*) > 1;

select * from salesdata
where transaction_id in ('TXN855235', 'TXN342128', 'TXN240646', 'TXN981773');

set SQL_safe_updates = 1;

with duplicate_cte as(
select *, row_number() over(partition by transaction_id order by transaction_id) as rownumber
from salesdata)
delete from salesdata
where transaction_id in ( select transaction_id from duplicate_cte where rownumber>1);


-- Step 2: correction of headers
select * from salesdata;

Alter table salesdata
rename column quantity to quantity;

Alter table salesdata
rename column prce to price;

-- To  check datatype

desc salesdata;

-- step - 4
-- Treating null values

select * from salesdata;

select * from salesdata
where transaction_id is null
or 
customer_id is null
or 
customer_name is null
or 
customer_age is null
or
gender is null
or
product_id is null
or
product_name is null
or
product_category is null
or
quantity is null
or
price is null
or
payment_mode is null
or
purchase_date is null
or
time_of_purchase is null
or
status is null;

set SQL_safe_updates = 0;

delete from salesdata
where transaction_id is null;

select * from salesdata
where customer_id = "cust1003";

update salesdata
set customer_name="mahika saini",customer_age=35,gender="male"
where customer_id="cust1003";

select * from salesdata
where customer_name = "Ehsaan Ram";

update salesdata
set customer_id="cust9494"
where customer_name = "Ehsaan Ram";

select * from salesdata
where customer_name = "Damini Raju";

update salesdata
set customer_id="cust1401"
where customer_name = "Damini Raju";

select * from salesdata;

-- Step - 5
-- Data Cleaning

select distinct gender from salesdata;

update salesdata
set gender = "M"
where gender = "Male";

update salesdata
set gender= "F"
where gender = "Female";

select distinct payment_mode from salesdata;

update salesdata
set payment_mode="credit card"
where payment_mode="CC";

-- part 4
-- Data Analysis -- 

-- What are the top 5 most selling products by quantity?
select * from salesdata;

select  product_name, sum(quantity) Sold_quantity from salesdata
where status = "delivered"
group by product_name
order by sold_quantity desc
limit 5;

-- Business problem - We don't know which product are most in demand.
-- Business Impact - It helps to prioritize stock and boost sales through targeted promotions.

select * from salesdata;
-- Which product are most frequently cancelled?
select product_name, count(*) Total_cancelled from salesdata
where status = "cancelled"
group by product_name
order by total_cancelled desc
limit 5;

-- Business problem: Frequent cancellations affect revenue and customer trust.
-- Business Impact: Indetify poor performing product to improve quality or remove from catalog.

-- What time of the day has the highest number of purchases?
select * from salesdata;

select case when hour(time_of_purchase) between 0 and 5  then "night" 
when hour(time_of_purchase) between 6 and 11 then "morning" 
when hour(time_of_purchase) between 12 and 17 then "afternoon" 
when hour(time_of_purchase) between 18 and 23 then "evening" 
end as time_of_day, count(*) as total_order from salesdata
group by 
case 
when hour(time_of_purchase) between 0 and 5  then "night" 
when hour(time_of_purchase) between 6 and 11 then "morning" 
when hour(time_of_purchase) between 12 and 17 then "afternoon" 
when hour(time_of_purchase) between 18 and 23 then "evening" 
end
order by total_order desc
;

select time_of_day, count(*) Total_Cancelled from (
select case 
when hour(time_of_purchase) between 0 and 5 then "night"
when hour(time_of_purchase) between 6 and 11 then "morning"
when hour(time_of_purchase) between 12 and 17 then "Afternoon"
when hour(time_of_purchase)between 18 and 23 then "evening"
end as time_of_day from salesdata ) T
group by time_of_day
order by total_cancelled desc;

-- Business problem solved: Find peak sales times
-- Business Impact: Optimize staffing, promotions, and server loads.

-- Who are the top 5 highest spending customers?

select * from salesdata;

select customer_name, sum(quantity*price) as Total_speding from salesdata
group by customer_name 
order by Total_speding desc
limit 5;

-- Business problem: Identify VIP customers
-- Business Impact: personalized offers, loyalty rewards, and retetions 

-- Which product category generate the highest revenue?
select * from salesdata;

select product_category, sum(price*quantity) Revenue from salesdata
group by product_category
order by revenue desc
limit 5;

-- Business problem: Refine product strategy, supply chain, and promotions.
-- allowing the business to invest more in high-margin and high-demand categories.

-- What is the return/cancellation rate per product category?

-- cancellatios

select * from salesdata;
select product_category, concat(format(count(case when status="cancelled" then 1 end)*100/count(*),"N3"),' %') as cancelled_percent
from sales
group by product_category
order by cancelled_percent desc;

-- return
select product_category, concat(format(count(case when status="returned" then 1 end)*100/count(*),"N3")," %") as returned_percentages from salesdata 
group by product_category 
order by returned_percentages desc;

-- Business Impact - Reduce returns, improve product descriptions/expectations.
-- Helps identify and fix product or logistics issues.

-- what is the most preferred payment mode?
select * from salesdata;
select payment_mode, count(*) total_count from salesdata
group by payment_mode
order by  total_count desc;

-- Business problem solved: know which payment options customers prefer.
-- Business Impact: streamline payment processing, prioritize popular modes.

-- How does age group affect purchasing behaviour.
select * from salesdata;

select min(customer_age), max(customer_age) from salesdata;

select customer_age_group, format(sum(quantity*price),'en-IN') Revenue from( 
select *,case when customer_age between 18 and 25 then "18-25"
when customer_age between 26 and 35 then "26-35"
when customer_age between 36 and 50 then "36-50"
else "50+"
end as customer_Age_group from salesdata)as Age
group by customer_age_group
order by sum(quantity*price) desc;

-- Business problem solved: Understand customer demographics.
-- Business Impact: Targeted marketing and product recomndations by age group.

-- Whats the monthly sales trend?
select * from salesdata;

-- method 1
select 
-- year(purchase_date) year, 
month(purchase_date)month, format(sum(quantity*price),'en-IN') Total_sale, sum(quantity) Total_quantity from salesdata
group by month(purchase_date)
order by month; 

-- method 2
select date_format(purchase_date, '%Y-%m') Month_Year, format(sum(quantity*price),'en-IN') Total_sale, sum(quantity) Total_quantity from salesdata
group by Month_year
order by sum(quantity*price) desc; 

-- Business problem: Sales fluctuations go unnoticed.
-- Business Impact: Plan inventory or marketing according to seasonal trends.

-- Are certain genders buying more specific product categories?
select * from salesdata;

-- method 1
select gender, product_category, count(product_category) from salesdata data
group by gender, product_category
order by gender;

-- method 2
select product_category, sum(case when gender='F' then 1 else 0 end) as Female, sum(case when gender="M" then 1 else 0 end) as Male from salesdata
group by product_category 
order by product_category;

-- Business problem: Gender-based product preferences.
-- Business Inpact: personalized ads, gender-focused campaigns













 





