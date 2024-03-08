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
SELECT film.title AS film_title, COUNT(rental.rental_id) AS total_rentals
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
GROUP BY film.title
ORDER BY total_rentals DESC
LIMIT 10;

-- 4.) Show how much each customer spent on movies (for all time), then order from least to most:
SELECT customer_id, SUM(amount) AS total
FROM payment
GROUP BY customer_id
ORDER BY total ASC;

-- 5.) Which actor was in the most movies in 2006 (based on this dataset)? 
-- Be sure to alias the actor name and count as a more descriptive name.
-- (Order results from most to least):
SELECT actor.actor_id, actor.first_name, actor.last_name, COUNT(DISTINCT film.film_id) AS movies_in_2006
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film ON film_actor.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
WHERE rental.rental_date BETWEEN '2006-01-01' AND '2006-12-31'
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY movies_in_2006 DESC;