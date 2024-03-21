-- 1.) Create a new column called “status” in the rental table (yes, add a permanent column)
-- that uses a case statement to indicate if a film was returned late, early, or on time:
ALTER TABLE rental
ADD COLUMN status varchar(7);

UPDATE rental
SET status = CASE
    WHEN rental_date > return_date THEN 'Late'
    WHEN rental_date < return_date THEN 'Early'
    ELSE 'On Time'
END;

-- 2.) Show the total payment amounts for people who live in Kansas City or Saint Louis:
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_payed
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN payment p ON c.customer_id = p.customer_id
WHERE ci.city IN ('Kansas City', 'Saint Louis')
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 3.) How many films are in each category in the dataset?
SELECT c.name AS category_name, COUNT(f.film_id) AS film_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name;

-- 4.) Why is there a table for category and a table for film category?
-- For the sake of explanation, I'll be synonymizing "category" with "genre": mostly for my own sake.
-- Essentially, any single film can have multiple genres (ex; Top Gun could be describes as both "action"
-- and "drama"). If you eliminated the film_category table, this would be disallowed, and films would have
-- to appear multiple times in the film table, once for each of their genres: that'd be a mess. Instead, the
-- film_category table acts as an intermediary—a place where such duplicates CAN exist—so films can be counted,
-- using their respective IDs, multiple times, across multiple genres.

-- 5.) Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005:
SELECT f.film_id, f.title, f.length
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.return_date BETWEEN '2005-05-15' AND '2005-05-31';

-- 6.) Write a subquery or join statement to show which movies are rented below the average price for all movies:
SELECT f.film_id, f.title, f.rental_rate
FROM film f
WHERE f.rental_rate < (
    SELECT AVG(rental_rate)
    FROM film
);

-- 7.) How many films were returned late? Early? On time?
EXPLAIN ANALYZE
SELECT status,
COUNT(*) AS total
FROM rental
GROUP BY status; 

-- 8.) With a window function, write a query that shows the film, its duration, and what percentile the duration fits into:
EXPLAIN ANALYZE
SELECT title, length, PERCENT_RANK() OVER (
	ORDER BY length) 
	AS percentile
FROM film;

-- 9.) Perform an explain plan on two different queries from above, and describe what you’re seeing and important ways they differ:
-- a.] After performing an EXPLAIN ANALYZE query on problem 7, SQL returned:
-- (cost=785.66..785.68 rows=2 width=14) (actual time=24.581..24.583 rows=2 loops=1)
-- Meaning SQL predicted the program to produce the output in 785.66ms (with a max of 785.68ms), over 2 rows.
-- In reality, the program took 24.581ms (with a max of 24.583ms), over just 2 rows.

-- b.] After performing an EXPLAIN ANALYZE query on problem 8, SQL returned:
-- (cost=147.83..165.33 rows=1000 width=25) (actual time=4.141..4.522 rows=1000 loops=1)
-- Meaning SQL predicted the program to produce the output in 147.83ms (with a max of 165.33ms), over 1000 rows.
-- In reality, the program took 4.141ms (with a max of 4.522ms), over the anticipated 1000 rows.

-- Perhaps the most notable difference between these two explain plans are their costs, including a predicted and far more
-- resource-intensive ~785.66ms to output the former, despite its more efficient actual result, to the latter's ~147.83 and
-- 4.141, respectively. This can be explained, in large part, due to the nature of each functions being analyzed. In problem
-- 7, we involve a more new and more complex—case statement-addled—column, as contrasted with the simpler percentile ranking
-- iterated over, in problem 8.

-- 10.) Find the relationship that is wrong in the data model. Explain why it’s wrong.
-- I have no idea, but I'll take your word for it.

-- 11.) In under 100 words, explain what the difference is between set-based and procedural programming.
-- Be sure to specify which sql and python are:
-- Set-based programming—SQL—is a matter of telling a computer "what" to do (eg; SELECT _ FROM _ GROUP BY _) on the WHOLE dataset,
-- without describing HOW to do so. Procedural programming—Python—is far more explicit, you are describing "what" to do AND "how" to
-- do it—you are guiding your program, row by row, to iterate over data, not all at once. In retrospect, the titles of both types of
-- programming are pretty self-explanatory!