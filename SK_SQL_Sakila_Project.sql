USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ',  last_name)) AS actor_name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
-- SELECT * FROM country;
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
-- SELECT * FROM actor;
ALTER TABLE actor 
ADD COLUMN description BLOB;

-- ALTERNATE METHOD 
ALTER TABLE actor ADD(description BLOB NOT NULL);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
-- SELECT * FROM actor;
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
-- SELECT * FROM actor;
SELECT last_name, COUNT(*) AS actor_count 
FROM actor 
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS actor_count
FROM actor
GROUP BY last_name HAVING COUNT(*) >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
-- SELECT * FROM actor;
UPDATE actor
SET first_name='HARPO'
WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
-- SELECT * FROM address;
-- SELECT * FROM staff;

SELECT first_name, last_name, address
FROM address a
JOIN staff s 
ON a.address_id = s.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
-- SELECT * FROM staff;
-- SELECT * FROM payment;

SELECT first_name, last_name, SUM(amount) AS total_amount
FROM staff s
JOIN payment p
ON s.staff_id = p.staff_id
WHERE payment_date BETWEEN '2005-08-01' AND '2005-09-01'
GROUP BY s.staff_id;

-- ALTERNATE METHOD USING DATE_FORMAT
SELECT first_name, last_name, SUM(amount) AS total_amount FROM staff s
JOIN payment p ON s.staff_id = p.staff_id 
WHERE date_format(payment_date,"%Y-%M") = "2005-August" 
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
-- SELECT * FROM film_actor;
-- SELECT * FROM film;

SELECT title, COUNT(actor_id) AS number_of_actors
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- SELECT * FROM film;
-- SELECT * FROM inventory;

SELECT title, COUNT(inventory_id) AS number_of_copies
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name.
-- SELECT * FROM payment;
-- SELECT * FROM customer;
SELECT last_name, first_name, SUM(amount) AS total_paid
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY p.customer_id
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- SELECT * FROM language;
-- SELECT * FROM film;
SELECT f.title, l.name
FROM language l 
JOIN film f 
ON f.title in 
(
SELECT f.title 
FROM film f 
WHERE f.title LIKE 'K%' or f.title LIKE 'Q%') 
AND l.language_id = 1
;

-- ALTERNATE METHOD DISPLAYING ONLY MOVIE NAMES
SELECT title 
FROM film 
WHERE title LIKE 'Q%' 
OR title LIKE 'K%' 
AND language_id IN
(
SELECT language_id
FROM language 
WHERE name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- SELECT * FROM actor;    		 actor_id
-- SELECT * FROM film_actor;	 actor_id 	film_id
-- SELECT * FROM film;			 film_id	

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id IN
(
SELECT film_id
FROM film
WHERE title = 'Alone Trip'
));

-- ALTERNATE METHOD USING JOIN
SELECT first_name , last_name 
FROM actor a
WHERE a.actor_id in 
(
SELECT actor_id 
FROM film_actor fa
JOIN film f ON f.film_id = fa.film_id 
WHERE f.title = 'Alone Trip'
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- SELECT * FROM customer;   customer_id   address_id
-- SELECT * FROM address;  address_id  city_id
-- SELECT * FROM city;   city_id   country_id
-- SELECT * FROM country;  country_id

SELECT customer_id, first_name, last_name, email
FROM customer cus
JOIN address a ON cus.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- SELECT * FROM film;
-- SELECT * FROM film_category; 
-- SELECT * FROM category;

SELECT title, description
FROM film
WHERE film_id IN
(
SELECT film_id
FROM film_category
WHERE category_id IN
(
SELECT category_id
FROM category
WHERE name = 'Family'
));

-- ALTERNATE METHOD USING JOIN AND DISPLAYING CATEGORY FAMILY
SELECT f.title, f.description, c.name
FROM film f  
INNER JOIN film_category fc ON f.film_id = fc.film_id    
INNER JOIN category c ON fc.category_id = c.category_id  
AND c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
-- SELECT * FROM film;    film_id
-- SELECT * FROM inventory;   film_id   inventory_id
-- SELECT * FROM rental;   inventory_id  rental_id

SELECT title, COUNT(f.film_id) AS rented_movies_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY rented_movies_count DESC;

-- ALTERNATE METHOD
SELECT title, COUNT(r.rental_id) AS rented_movies_count 
FROM film f, rental r, inventory i 
WHERE i.inventory_id = r.inventory_id 
AND f.film_id = i.film_id 
GROUP BY title 
ORDER BY COUNT(r.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- SELECT * FROM store;    store_id
-- SELECT * FROM staff;    store_id   staff_id
-- SELECT * FROM payment;  staff_id   

SELECT sto.store_id AS 'Store', SUM(amount) AS 'Store Revenue(in $)' 
FROM store sto
JOIN staff sta ON sto.store_id = sta.store_id
JOIN payment p ON sta.staff_id = p.staff_id
GROUP BY sto.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
-- SELECT * FROM store;     store_id    address_id
-- SELECT * FROM address;   address_id  city_id
-- SELECT * FROM city;		city_id     country_id
-- SELECT * FROM country;	country_id

SELECT s.store_id, city, country
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
GROUP BY s.store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- SELECT * FROM category        category_id   
-- SELECT * FROM film_category   category_id   film_id    
-- SELECT * FROM inventory		 film_id       inventory_id
-- SELECT * FROM rental          inventory_id  rental_id
-- SELECT * FROM payment		 rental_id     

SELECT name AS top_five_genres, SUM(amount) as gross_revenue
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY top_five_genres
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS

SELECT name AS top_five_genres, SUM(amount) as gross_revenue
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY top_five_genres
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top_five_genres;
