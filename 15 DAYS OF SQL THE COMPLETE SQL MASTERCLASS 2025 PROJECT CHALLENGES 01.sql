-- Challenge 01: Create a list of all the different (distinct) replacement costs of the films--
--Question: What's the lowest replacement cost?--

SELECT DISTINCT replacement_cost FROM film
SELECT MIN(replacement_cost) FROM film --Answer: 9.99--


--Challenge 02: Write a query that gives an overview of how many films have replacements costs in the following cost ranges: low: 9.99 - 19.99, medium: 20.00 - 24.99, high: 25.00 - 29.99--
--Question: How many films have a replacement cost in the "low" group?--
SELECT 
CASE
WHEN replacement_cost >= 9.99 AND replacement_cost <= 19.99 THEN 'Low replacement cost'
WHEN replacement_cost >= 20.00 AND replacement_cost <= 24.99 THEN 'Medium replacement cost'
WHEN replacement_cost >= 25.00 AND replacement_cost <= 29.99 THEN 'High replacement cost' --it became correct when i put the equal signs too--
ELSE 'Outside scope'
END AS replacement_cost_categories,
COUNT(*)
FROM film
GROUP BY replacement_cost_categories --Answer: 514--


--Challenge 03: Create a list of the film titles including their title, length, and category name ordered descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'--
--Question: In which category is the longest film and how long is it?--
SELECT title, length, name FROM film
LEFT JOIN film_category
ON film.film_id = film_category.film_id 
LEFT JOIN category 
ON film_category.category_id = category.category_id
WHERE name = 'Drama' OR name = 'Sports'
ORDER BY length DESC

SELECT name, length FROM film
LEFT JOIN film_category
ON film.film_id = film_category.film_id 
LEFT JOIN category 
ON film_category.category_id = category.category_id
WHERE (name = 'Drama' OR name = 'Sports')
ORDER BY length DESC
LIMIT 1 --Answer: Sports:184--


--Challenge 04: Create an overview of how many movies (titles) there are in each category (name)--
--Question: Which category (name) is the most common among the films?--
SELECT name, count(title) as count_titles FROM film
LEFT JOIN film_category
ON film.film_id = film_category.film_id 
LEFT JOIN category 
ON film_category.category_id = category.category_id
GROUP BY name
ORDER BY count_titles DESC --Answer: Sports with 74 titles--


--Challenge 05: Create an overview of the actors' first and last names and in how many movies they appear in--
--Question: Which actor is part of most movies?--
SELECT first_name, last_name, count(film_id) FROM actor 
LEFT JOIN film_actor 
ON actor.actor_id = film_actor.actor_id
GROUP BY first_name, last_name
ORDER BY count(film_id) DESC --Answer: Susan Davis with 54 movies--


--Challenge 06: Create an overview of the addresses that are not associated to any customer--
--Question: How many addresses are that?--
SELECT address, customer_id FROM address
LEFT JOIN customer
ON address.address_id = customer.address_id
WHERE customer_id IS null --Answer: 4 addresses--


--Challenge 07: Create the overview of the sales  to determine the from which city (we are interested in the city in which the customer lives, not where the store is) most sales occur--
--Question: What city is that and how much is the amount?--
SELECT city, sum(amount) FROM payment 
LEFT JOIN customer 
ON payment.customer_id = customer.customer_id
LEFT JOIN address
ON customer.address_id = address.address_id
LEFT JOIN city
ON address.city_id = city.city_id
GROUP BY city
ORDER BY sum(amount) DESC --Answer: Cape Coral with a total amount of 221.55--


--Challenge 08: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city"--
--Question: Which country, city has the least sales?--
SELECT country ||', '|| city AS country_city, sum(amount) FROM payment 
LEFT JOIN customer 
ON payment.customer_id = customer.customer_id
LEFT JOIN address
ON customer.address_id = address.address_id
LEFT JOIN city
ON address.city_id = city.city_id
LEFT JOIN country
ON city.country_id = country.country_id
GROUP BY country_city
ORDER BY sum(amount) ASC --Answer: United States, Tallahassee with a total amount of 50.85--


--Challenge 09: Create a list with the average of the sales amount each staff_id has per customer--
--Question: Which staff_id makes on average more revenue per customer?--
SELECT staff_id, AVG(sum_amount) FROM 
(SELECT staff_id, 
customer_id, 
sum(amount) AS sum_amount
FROM payment
GROUP BY staff_id, customer_id
ORDER BY staff_id, customer_id)
GROUP BY staff_id --Answer: staff_id 2 with an average revenue of 56.64 per customer--


--Challenge 10: Create a query that shows average daily revenue of all Sundays--
--Question: What is the daily average revenue of all Sundays?--
SELECT ROUND(AVG(sum_amount),2) FROM 
(SELECT DATE(payment_date), EXTRACT(dow from payment_date) AS dow, sum(amount) AS sum_amount FROM payment
WHERE  EXTRACT(dow from payment_date) = 0
GROUP BY DATE(payment_date), dow
ORDER BY DATE(payment_date)) --Answer: 1428.60 (Wrong, it should be 1410.65)--


--Challenge 11: Create a list of movies - with their length and their replacement cost - that are longer than the average length in each replacement cost group--
--Question: Which two movies are the shortest on that list and how long are they?--
SELECT  title, length, replacement_cost FROM film f1 
WHERE length > (SELECT AVG(length) FROM film f2 WHERE f1.replacement_cost= f2.replacement_cost)
ORDER BY length ASC --Answer: CELEBRITY HORN and SEATTLE EXPECTATIONS with 110 minutes--


--Challenge 12: Create a list that shows the "average customer lifetime value" grouped by the different districts--
--Question: Which district has the highest average customer lifetime value?--
SELECT district, ROUND(AVG(sum_amount),2) FROM
(SELECT district, customer.customer_id, sum(amount) as sum_amount FROM address --In the solution, the tutor joins in this sequence: payment table, customer table, address table--
LEFT JOIN customer 
ON address.address_id = customer.address_id
LEFT JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY district, customer.customer_id
ORDER BY customer.customer_id)
GROUP BY district 
ORDER BY AVG(sum_amount) DESC --Answer: Saint-Denis with an average customer lifetime value of 216.54--


--Challenge 13:  Create a list that shows all payments including the payment_id, amount, and the film category (name) plus the total amount that was made in this category. Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendingly--
--Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?--
SELECT 
payment_id, 
amount, 
name,
(SELECT sum(amount) FROM payment 
LEFT JOIN rental
ON payment.rental_id = rental.rental_id
LEFT JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film
ON inventory.film_id = film.film_id
LEFT JOIN film_category
ON film.film_id = film_category.film_id
LEFT JOIN category c2
ON film_category.category_id = c2.category_id WHERE c1.name=c2.name)

FROM payment 
LEFT JOIN rental
ON payment.rental_id = rental.rental_id
LEFT JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film
ON inventory.film_id = film.film_id
LEFT JOIN film_category
ON film.film_id = film_category.film_id
LEFT JOIN category c1
ON film_category.category_id = c1.category_id
ORDER BY name ASC, payment_id ASC --Answer: Total revenue in the category 'Action' is 4375.85 and the lowest payment_id in that category is 16055--


--Challenge 14: Create a list with the top overall revenue of a film title (sum of amount per title) for each category (name)--
--Question: Which is the top-performing film in the animation category?--
SELECT 
name, 
title, 
sum(amount) as total
FROM payment 
LEFT JOIN rental
ON payment.rental_id = rental.rental_id
LEFT JOIN inventory 
ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film
ON inventory.film_id = film.film_id
LEFT JOIN film_category
ON film.film_id = film_category.film_id
LEFT JOIN category 
ON film_category.category_id = category.category_id 
GROUP BY name, title
HAVING sum(amount) = 
  (SELECT MAX(total) FROM 
    (SELECT
     name, 
     title, 
     sum(amount) as total
     FROM payment 
     LEFT JOIN rental
     ON payment.rental_id = rental.rental_id
     LEFT JOIN inventory 
     ON rental.inventory_id = inventory.inventory_id
     LEFT JOIN film
     ON inventory.film_id = film.film_id
     LEFT JOIN film_category
     ON film.film_id = film_category.film_id
     LEFT JOIN category 
     ON film_category.category_id = category.category_id 
     GROUP BY name, title) sub
     WHERE category.name = sub.name) 