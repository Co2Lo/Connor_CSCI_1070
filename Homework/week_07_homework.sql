-- 1.) Show all customers whose last names start with T and order them by first name:
SELECT * FROM customer
WHERE last_name LIKE 'T%'
ORDER BY first_name ASC;

-- 2.) Show all rentals returned from 5/28/2005 to 6/1/2005:
SELECT * FROM rental
WHERE return_date >= '2005-05-28' AND return_date <= '2005-06-01';

-- 3.) What query would you use to determine which movies are rented the most?
--     Show the top 10 movies rented the most:
SELECT film.title AS film_title, COUNT(rental.rental_id) AS top_rented FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
GROUP BY film.title
ORDER BY top_rented DESC
LIMIT 10;

-- 4.) Show how much each customer spent on movies (for all time), then order from least to most:
EXPLAIN ANALYZE SELECT customer_id, SUM(amount) AS total
FROM payment
GROUP BY customer_id
ORDER BY total ASC;

-- 5.) Which actor was in the most movies in 2006 (based on this dataset)? 
-- Be sure to alias the actor name and count as a more descriptive name.
-- (Order results from most to least):
EXPLAIN ANALYZE SELECT actor.actor_id, actor.first_name, actor.last_name, COUNT(DISTINCT film.film_id) AS movies_in_2006 FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film ON film_actor.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE rental.rental_date BETWEEN '2006-01-01' AND '2006-12-31'
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY movies_in_2006 DESC;


-- 6.) Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one.
-- After performing EXPLAIN ANALYZE QUERIES on each problem 4 and 5, I was returned:
-- (For 4): Sort (cost=362.06..363.56 rows=599 width = 34) (actual time=3.291..3.304 rows=599 loops=1)
-- Meaning SQL predicted the program to take 362.06ms before it produced an output, with a max of 363.56ms, over 599 rows.
-- In reality, the program took 3.291ms, with a max of 3.304ms, over the anticipated 599 rows.

-- (For 5): Sort (cost=403.20..403.70 rows=200 width=25) (actual time=1.422..1.428 rows=198 loops=1)
-- In the same form as above, sql expected an output time (startup cost) of 403.20ms, max of 403.70ms, over 200 rows returned.
-- In reality, we exceeded expectations again, producing an output in 1.422ms with a max of 1.428ms, over 198—rather than 200—rows.

-- 7.) What is the average rental rate per genre?
SELECT category.name AS genre, AVG(film.rental_rate) AS avg_rentrate FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
GROUP BY category.name;
	
-- 8.) What categories are the most rented and what are their total sales? Show the top 5 most rented categories.
WITH TopCats AS (SELECT category.category_id, COUNT(*) as rentals_count FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY category.category_id
ORDER BY rentals_count DESC 
LIMIT 5)

SELECT category.name AS category, SUM(payment.amount) AS total_rental_sales FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
JOIN TopCats ON category.category_id = TopCats.category_id
GROUP BY category.name;

-- 9.) Write a query that shows how many total films were rented each month.
-- Group them by category and month. So, you want to show January in general regardless of year, etc. 
SELECT category.name AS category_name, MONTH(rental.rental_date) AS rental_month, 
COUNT(rental.rental_id) AS total_rentals FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY category.name, MONTH(rental.rental_date)
ORDER BY category_name,rental_month;