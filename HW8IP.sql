-- 1.) Show all customers whose last names start with T and order them by first name:

SELECT *
FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name ASC;

-- 2.) Show all rentals returned from 5/28/2005 to 6/1/2005:
SELECT *
FROM rental
WHERE return_date >= '2005-05-28' AND return_date <= '2005-06-01';

-- 3.) What query would you use to determine which movies are rented the most?
--     Show the top 10 movies rented the most:
SELECT inventory_id SUM(amount) AS total
from rental
limit 10;

-- 4.) Show how much each customer spent on movies (for all time), then order from least to most:
SELECT customer_id, SUM(amount) AS total
FROM payment
GROUP BY customer_id
ORDER BY total ASC;

-- 5.) Which actor was in the most movies in 2006 (based on this dataset)? 
-- Be sure to alias the actor name and count as a more descriptive name.
-- (Order results from most to least):


--6.) Write an explain plan for 4 and 5. Show the queries and explain what is
-- happening in each one. Use the following link to understand how this works 
-- (http://postgresguide.com/performance/explain.html)