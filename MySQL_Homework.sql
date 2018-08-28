-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters.
-- Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query you would use to obtain this information?
SELECT first_name, last_name, actor_id
FROM actor a
WHERE first_name = 'Joe'
GROUP BY (actor_id);
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%';
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country 
WHERE country 
IN ('Afghanistan', 'Bangladesh', 'China');
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create 
-- a column in the table actor named description and use the data type BLOB.
ALTER TABLE actor ADD description BLOB;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS actor_count
FROM actor
GROUP BY(last_name);
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS actor_count 
FROM actor 
GROUP BY(last_name) 
HAVING COUNT(last_name) >= 2 
ORDER BY(actor_count) DESC;
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO';
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address 
FROM staff s 
JOIN address a USING(address_id);
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount) AS 'August_sales' 
FROM staff s 
JOIN payment p USING(staff_id) 
WHERE p.payment_date LIKE '2005-08%'
GROUP BY s.first_name, s.last_name;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS 'Actors in Film' 
FROM film f 
INNER JOIN film_actor fa USING(film_id) 
GROUP BY(title);
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(i.film_id) AS 'Inventory Count' 
FROM inventory i 
JOIN film f USING(film_id) 
WHERE title = 'Hunchback Impossible';
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total' 
FROM customer c 
JOIN payment p USING(customer_id) 
GROUP BY c.first_name, c.last_name 
ORDER BY(c.last_name);
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q 
-- have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT 
    f.title, (SELECT l.name FROM language l 
WHERE name = 'English') AS 'language' 
FROM film f 
WHERE f.title LIKE 'K%' OR f.title LIKE 'Q%';
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor 
WHERE actor_id IN 
(SELECT actor_id FROM film_actor WHERE film_id = 
(SELECT film_id FROM film 
WHERE title = 'Alone Trip'));
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email 
FROM customer c 
JOIN address USING(address_id) 
JOIN city USING(city_id) 
JOIN country USING(country_id) 
WHERE country = 'Canada';
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title 
FROM film f 
JOIN film_category USING(film_id) 
JOIN category USING(category_id) 
WHERE name = 'Family';
-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, r.rental_date 
FROM film f 
JOIN inventory USING(film_id) 
JOIN rental r USING(inventory_id) 
ORDER BY(rental_date) DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, CONCAT('$', format(COUNT(p.amount), 2)) AS 'total' 
FROM store s 
JOIN staff USING(store_id) 
JOIN payment p USING(staff_id) 
GROUP BY(store_id);
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country 
FROM store s 
JOIN address USING(address_id) 
JOIN city c USING(city_id)
JOIN country co USING(country_id);
-- 7h. List the top five genres in gross revenue in descending order.
SELECT c.name, SUM(p.amount) AS 'total'
FROM category c 
JOIN film_category USING(category_id) 
JOIN inventory USING(film_id) 
JOIN rental USING(inventory_id) 
JOIN payment p USING(customer_id) 
GROUP BY(name) 
ORDER BY (total) DESC 
LIMIT 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
CREATE OR REPLACE VIEW top_five AS 
SELECT c.name, SUM(p.amount) AS 'total'
FROM category c 
JOIN film_category USING(category_id) 
JOIN inventory USING(film_id) 
JOIN rental USING(inventory_id) 
JOIN payment p USING(customer_id) 
GROUP BY(name) 
ORDER BY (total) DESC 
LIMIT 5;
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five;
-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five;