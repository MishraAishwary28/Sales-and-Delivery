#Creating database
CREATE DATABASE miniproject;

#Using database
USE miniproject;

# Datasets used:-

#1.Imported Sales and Delivery dataset consisting following tables:-
SELECT * FROM cust_dimen;
SELECT * FROM market_fact;
SELECT * FROM orders_dimen;
SELECT * FROM prod_dimen;
SELECT * FROM shipping_dimen;

#2.Imported Restaurant dataset consisting following tables:-
SELECT * FROM chefmozaccepts;
SELECT * FROM chefmozcuisine;
SELECT * FROM chefmozhours4;
SELECT * FROM geoplaces2;
SELECT * FROM rating_final;
SELECT * FROM usercuisine;
SELECT * FROM userpayment;
SELECT * FROM userprofile;
SELECT * FROM chefmozparking;
#####################################################################################################################################
													#PART-1
# Question 1: Find the top 3 customers who have the maximum number of orders
#A. ON the basis of order_id
SELECT * FROM market_fact;
SELECT c.customer_name,m.cust_id,COUNT(m.ord_id) AS total_orders
FROM market_fact m JOIN cust_dimen c
ON m.cust_id=c.cust_id
GROUP BY m.cust_id
ORDER BY COUNT(m.cust_id) DESC
LIMIT 3;

#B. ON the basis of quantity
SELECT c.customer_name,m.cust_id,SUM(m.order_quantity) AS total_orders
FROM market_fact m JOIN cust_dimen c
ON m.cust_id=c.cust_id
GROUP BY m.cust_id
ORDER BY SUM(m.order_quantity) DESC
LIMIT 3;
-- --------------------------------------------------------------------------------------------------------------
#Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_date AND Ship_date.
UPDATE orders_dimen SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y');
UPDATE shipping_dimen SET ship_date = STR_TO_DATE(ship_date, '%d-%m-%Y');
SELECT o.order_id,o.order_date,s.ship_date,
DATEDIFF(s.ship_date,o.order_date) AS DaysTakenForDelivery
FROM orders_dimen o JOIN shipping_dimen s
ON o.order_id=s.order_id;
-- -------------------------------------------------------------------------------------------------------------------------------
#Question 3: Find the customer whose order took the maximum time to get delivered.
SELECT o.order_id,o.order_date,s.ship_date,
DATEDIFF(s.ship_date,o.order_date) AS DaysTakenForDelivery
FROM orders_dimen o JOIN shipping_dimen s
ON o.order_id=s.order_id
ORDER BY DATEDIFF(s.ship_date,o.order_date) DESC
LIMIT 1;
-- ---------------------------------------------------------------------------------------------------------------------------
#Question 4: Retrieve total sales made by each product FROM the data (use Windows function)
SELECT * FROM market_fact;
SELECT prod_id,sum(sales) OVER(PARTITION BY prod_id) AS total_sales
FROM market_fact;
-- --------------------------------------------------------------------------------------------------------------------------
#Question 5: Retrieve the total profit made FROM each product FROM the data (use windows functiON)
SELECT prod_id,sum(profit) OVER(PARTITION BY prod_id) AS total_profit
FROM market_fact;
-- ---------------------------------------------------------------------------------------------------------------------
# Question 6: Count the total number of unique customers in January and
-- how many of them came back every month over the entire year in 2011.

SELECT m.cust_id, COUNT(DISTINCT MONTH(STR_TO_DATE(order_Date, '%d-%m-%Y'))) AS number_of_months
FROM market_fact m JOIN orders_dimen o
ON m.ord_id=o.ord_id
WHERE YEAR(STR_TO_DATE(order_Date, '%d-%m-%Y')) = 2011
GROUP BY m.cust_id;
#HAVING COUNT(DISTINCT MONTH(STR_TO_DATE(order_Date, '%d-%m-%Y'))) = 12;

######################################################################################################################################
														#PART-2
# Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
SELECT r.placeid,g.alcohol,COUNT(r.userid)  AS total_visits
FROM rating_final r INNER JOIN geoplaces2 g
ON r.placeid=g.placeid
GROUP BY placeid , alcohol;
# WHERE g.alcohol NOT LIKE '%no_alcohol%';
-- ------------------------------------------------------------------------------------------------------------------------
# Question 2: -Let's find out the average rating according to alcohol 
-- and price so that we can understand the rating in respective price categories as well.
SELECT AVG(r.rating)AS average_rating,g.alcohol,g.price
FROM rating_final r INNER JOIN geoplaces2 g
ON r.placeid=g.placeid
WHERE g.alcohol NOT LIKE '%no_alcohol%'
GROUP BY alcohol,price;
-- --------------------------------------------------------------------------------------------------------------------
# Question 3:  Let’s write a query to quantify that what are the parking availability 
-- as well in different alcohol categories along with the total number of restaurants.
SELECT g.alcohol,COUNT(g.name) AS total_restaurant ,p.parking_lot
FROM geoplaces2 g JOIN chefmozparking p
ON g.placeid=p.placeid
GROUP BY alcohol , parking_lot ORDER BY alcohol;
-- -----------------------------------------------------------------------------------------------------------------
# Question 4: -Also take out the percentage of different cuisine in each alcohol type.
SELECT g.alcohol,c.rcuisine,COUNT(c.rcuisine) OVER(PARTITION BY g.alcohol) AS total_cuisine,
((COUNT(c.rcuisine) OVER(PARTITION BY g.alcohol,c.rcuisine))/(COUNT(c.rcuisine) OVER(PARTITION BY g.alcohol)))*100 AS percent_of_cuisine
FROM geoplaces2 g INNER JOIN chefmozcuisine c
ON g.placeid=c.placeid;

-- ----------------------------------------------------------------------------------------------------------------
#Questions 5: - let’s take out the average rating of each state.
SELECT g.state,AVG(r.rating)  AS avg_rating,
AVG(r.food_rating)  AS avg_food_rating,AVG(r.service_rating) AS avg_service_rating
FROM rating_final r INNER JOIN geoplaces2 g
ON r.placeid=g.placeid
GROUP BY state;

-- -------------------------------------------------------------------------------------------------------------
#Questions 6: -' Tamaulipas' Is the lowest average rated state. 
-- Quantify the reason why it is the lowest rated by providing the summary onthe basis of State, alcohol, and Cuisine.
SELECT g.placeid,g.state,g.alcohol,c.rcuisine,uc.userid
FROM geoplaces2 g JOIN chefmozcuisine c
ON g.placeid=c.placeid
JOIN usercuisine uc
ON uc.rcuisine=c.rcuisine 
WHERE state like '%Tamaulipas%';
/* FROM the output,we inferred that all the restaurants located in state of Tamaulipas' don't serve alcohol and also most of
   the customers have ordered just Mexican food in Tamaulipas' restaurants and not other type of cuisines.
   Thus,we can say that,these are the reasons why ' Tamaulipas' is the lowest average rated state.*/


-- -------------------------------------------------------------------------------------------------------------------------------
#Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and 
-- tried Mexican or Italian types of cuisine, and also their budget level is low.
-- We encourage you to give it a try by not using joins.

SELECT u.userid,g.placeid,g.name,r.food_rating,r.service_rating,uc.rcuisine,AVG(u.weight) OVER(PARTITION BY u.userid) AS AVG_weight,
u.budget
FROM geoplaces2 g , rating_final r ,usercuisine uc , userprofile u
WHERE  g.placeid=r.placeid AND uc.userid=r.userid AND
u.userid=uc.userid
AND g.name='KFC' AND uc.rcuisine IN ('mexican','italian') AND u.budget='low' ;


#######################################################################################################################################
															#PART-3
#Creating TABLE student details
CREATE TABLE student_details(
student_id int(4),
student_name varchar(20),
mail_id varchar(40),
mobile_no varchar(50)
);

# inserting data into student details
INSERT INTO student_details VALUES
(6,'Tamanna','tamanna@gl.com',8976547247),
(2,'Aishwarya','Aishwarya@gl.com',9678347247),
(3,'Shreyas','Shreyas@gl.com',9875677247),
(4,'Rahul','Rahul@gl.com',9566547247),
(5,'Vaishnavi','Vaishnavi@gl.com',8935247247);

SELECT * FROM student_details;

#Creating TABLE student_details_backup
CREATE TABLE student_details_backup(
student_id int(4),
student_name varchar(20),
mail_id varchar(40),
mobile_no varchar(50)
);
SELECT * FROM student_details_backup;

/*Trigger: A trigger is a stored procedure in database which automatically invokes whenever a special event in the database occurs.*/
# Creating Trigger named as sql_student (AFTER INSERT)
/*AFTER triggers run the trigger action after the triggering statement is run. */
# It will first insert data into backup TABLE then only it will delete the same record from 1st TABLE which is student_details
CREATE TRIGGER sql_students 
AFTER INSERT 
ON student_details_backup 
FOR EACH ROW
DELETE FROM student_details WHERE student_id=new.student_id;
# inserting data into backup TABLE
INSERT INTO student_details_backup
values(6,'Tamanna','tamanna@gl.com',8976547247);

# After inserting the same data into backup TABLE it will delete that record from 1st TABLE.
SELECT * FROM student_details_backup;
SELECT * FROM student_details;

#---------------------------------------------------------------------------------------------

# Creating Trigger named as sql_student2 (BEFORE DELETE)
/*BEFORE triggers run the trigger action before the triggering statement is run.*/
# It will first insert data into backup TABLE then only it will delete the same record from 1st TABLE which is student_details
# Basically AFTER INSERT AND BEFORE DELETE work similar and give same output.
CREATE trigger sql_students2 
BEFORE DELETE 
ON student_details 
FOR EACH ROW
INSERT INTO student_details_backup VALUES(old.student_id,old.student_name,old.mail_id,old.mobile_no);

DELETE FROM student_details WHERE student_name='Tamanna';

show triggers;
drop trigger sql_students2;
