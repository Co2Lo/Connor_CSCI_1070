-- Question 1:
select *
from payment
where amount >= 9.99;

-- Question 2:
SELECT MAX(amount)
FROM payment;
-- Max price is 11.99, rental_id's for all movies with that price are:
-- (8831, 3973, 4383, 16040, 11479, 14763, 15415, 14759)

-- Question 3:
SELECT first_name, last_name, email, address, city, country
from staff s
left join address a
on s.address_id = a.address_id
left join city c
on a.city_id = c.city_id
left join country l
on c.country_id = l.country_id

-- Question 4:
-- I'm interested in building financial models and providing
-- as much pro-bono consultation for small businesses and
-- low-income families as possible, while earning a living.

-- Question 5:
-- The crow's foot notation between "film" and "inventory"
-- means that a member of the film database can optionally
-- affect/create MULTIPLE entries in the "inventory" slot.
-- This makes sense, logically, as there can be many of the
-- same movie in storage, so many copies can be rented at once.
-- On the flip side, inventory MUST only affect the "films"
-- category in one way——that film's ID——because even if there
-- are multiple copies of one movie on file, it is, and only
-- should be, assigned one ID.