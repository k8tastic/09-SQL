use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT
	Last_Name
    ,First_Name
FROM
	actor;
   
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(First_Name, ' ', Last_Name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
    Actor_ID 
    ,First_Name
    ,Last_Name
FROM
	actor
WHERE
	First_Name ='Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT 
    Actor_ID
    ,First_Name
    ,Last_Name
FROM
	actor
WHERE
	Last_Name LIKE '%gen%';
    
-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT 
    Actor_ID
    ,First_Name
    ,Last_Name
FROM
	actor
WHERE
	Last_Name LIKE '%li%'
ORDER BY
	Last_Name
    ,First_Name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:  
SELECT
	country_id
    ,country
FROM 
	country
WHERE 
	country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB AFTER `last_update`;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `description`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT
	Last_Name
	,count(*) AS 'Count'
FROM
	actor
GROUP BY
	Last_Name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT
	Last_Name
	,count(*) AS 'Count'
FROM
	actor
GROUP BY
	Last_Name
HAVING
	COUNT(*) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET First_Name = "HARPO"
WHERE Last_Name = "WILLIAMS"
AND First_Name = "GROUCHO";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET First_Name = "GROUCHO"
WHERE Last_Name = "WILLIAMS"
AND First_Name = "HARPO";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
DESCRIBE `sakila`.`address`;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT
	s.address_id
    ,First_Name
    ,Last_Name
    ,a.address
FROM
	staff s
	INNER JOIN address a 
	ON s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT
	s.staff_id
    ,First_Name
    ,Last_Name
    ,sum(p.amount) as 'Total_Amount'
FROM 
	payment p 
	INNER JOIN staff s 
	ON s.staff_id = p.staff_id
WHERE 
	p.payment_date LIKE '2005-08%'
GROUP By
	staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT 
	title
    ,count(actor_id) AS 'actor_count'
FROM 
	film f
	INNER JOIN film_actor a
	ON f.film_id = a.film_id
GROUP BY 
	title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT 
	title
    ,count(inventory_id) AS 'inventory'
FROM film f
	INNER JOIN inventory i 
	ON f.film_id = i.film_id
WHERE
	title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
	first_name
    ,last_name
    ,sum(amount) AS 'total_paid'
FROM payment p
	INNER JOIN customer c
	ON p.customer_id = c.customer_id
GROUP BY 
	p.customer_id
ORDER BY 
	last_name ASC;
  
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT 
	title 
FROM 
	film
WHERE 
	language_id IN (SELECT language_id FROM language WHERE name = "english") 
	AND (title like "K%") 
	OR (title like "Q%");
    
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT
	first_name
    ,last_name
FROM
	actor
WHERE
	actor_id IN (SELECT actor_id FROM film_actor
	WHERE film_id IN (SELECT film_id FROM film WHERE title = 'ALone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT
	first_name
    ,last_name
    ,email
    ,country
FROM
	customer c
	INNER JOIN address a
    ON c.address_id = a.address_id
	INNER JOIN city ci
	ON a.city_id = ci.city_id
	INNER JOIN country cu
	ON ci.country_id = cu.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT
	f.title
    ,c.name
FROM
	film f
	INNER JOIN film_category fc
    ON f.film_id = fc.film_id
	INNER JOIN category c
	ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT
	title
    ,count(rental_id) AS 'total_rental' 
FROM
	film f
    INNER JOIN inventory i
    ON f.film_id = i.film_id
    INNER JOIN rental r
    ON i.inventory_id = r.inventory_id    
GROUP BY
	title
ORDER BY
	total_rental DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT
	store_id
    ,sum(amount) AS 'total_amount' 
FROM
	staff s
    INNER JOIN payment p
    ON s.staff_id = p.staff_id   
GROUP BY
	store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT
	store_id
    ,city
    ,country
FROM
	store s
    INNER JOIN address a
    ON s.address_id = a.address_id
    INNER JOIN city c
    ON a.city_id = c.city_id
    INNER JOIN country co
    ON c.country_id = co.country_id;
    
-- 7h. List the top five genres in gross revenue in descending order. (category, film_category, inventory, payment, and rental.)
SELECT
	name AS 'genre'
    ,sum(amount) AS 'total_amount' 
FROM
	payment p
    INNER JOIN rental r
    ON p.rental_id = r.rental_id
    INNER JOIN inventory i
    ON r.inventory_id = i.inventory_id    
    INNER JOIN film_category fc
    ON i.film_id = fc.film_id
    INNER JOIN category c
    ON fc.category_id = c.category_id
GROUP BY
	genre
ORDER BY
	total_amount DESC;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT 
	name AS 'genre'
    ,sum(amount) AS 'total_amount' 
FROM
	payment p
    INNER JOIN rental r
    ON p.rental_id = r.rental_id
    INNER JOIN inventory i
    ON r.inventory_id = i.inventory_id    
    INNER JOIN film_category fc
    ON i.film_id = fc.film_id
    INNER JOIN category c
    ON fc.category_id = c.category_id
GROUP BY
	genre
ORDER BY
	total_amount DESC
LIMIT 5;
    
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;

-- Using your `gwsis` database, develop a stored procedure that will drop an individual students
-- enrollment from a class. Be sure to refer to the existing stored procedures, `enroll_student`
-- and `terminate_all_class_enrollment` in the `gwsis` database for reference.

-- The procedure should be called `terminate_student_enrollment` and should accept the 
-- course code, section, student ID, and effective date of the withdrawal as parameters.
USE gwsis;

DELIMITER $$

CREATE PROCEDURE `terminate_student_enrollment`
(
CourseCode_out varchar(45),
Section_out varchar(45),
StudentID_out varchar(45),
EffectiveDate_out date
)

BEGIN

UPDATE
   classparticipant cp
   INNER JOIN class c
   ON cp.ID_Class = c.ID_Class
   INNER JOIN course co
   ON c.ID_Course = co.ID_Course
   INNER JOIN student s
   ON cp.ID_Student = s.ID_Student
SET
    cp.EndDate = NOW()
WHERE
    CourseCode = CourseCode_out
    AND Section = Section_out
    AND StudentID = StudentID_out;
    
END$$ 
