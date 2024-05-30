

--Select the first_name and the last_name of each actor. This query should result in selecting 2 columns.

SELECT first_name , last_name 
FROM actor;

-- Select the full name of the actor. This query should result in 1 column.
SELECT first_name||' '||last_name AS Full_Name
FROM actor;


-- Select the actors that have names starting with a ‘D’.


SELECT * 
FROM actor 
WHERE first_name LIKE 'D%' OR first_name LIKE '%d';



-- Select all the actor information sorted by the first name ascending.
SELECT * FROM actor
ORDER BY first_name;

--Count the unique actor’s first names

SELECT COUNT(DISTINCT(first_name))
FROM actor;


--Count the number of films based on their rental duration. rental_duaration in the film table referes to how long is the DVD allowed to be rented.
SELECT  COUNT(title) ,rental_duration
FROM film 
GROUP BY rental_duration
ORDER BY rental_duration;


--Select the maximum replacement cost
SELECT MAX(replacement_cost)
FROM film;


-- Select the titles of the movies that have the highest replacement cost.

SELECT title, replacement_cost
FROM film
WHERE replacement_cost = (
    SELECT MAX(replacement_cost)
    FROM film
);

-- Select the unique different ratings for the movies in the film table.

SELECT DISTINCT rating AS unique_rating
FROM film;

--Select the number of movies available under each rating.
SELECT COUNT(*) AS number_of_movies , rating
FROM film
GROUP BY rating;


-- Change the movie language for the first 20 movies from English language to Italian

UPDATE film 
SET language_id = (SELECT language_id FROM language WHERE name = 'Italian')
WHERE film_id <=20;

-- Select the count of movies grouped by language
SELECT COUNT(*) , language_id 
FROM film 
GROUP BY language_id;

--Select the language that most of the movies belong to.

SELECT name 
FROM language
WHERE language_id = (SELECT language_id 
FROM film
GROUP BY language_id 
ORDER BY (language_id) ASC LIMIT 1);

---CTE APPROACH FOR THE SAME PROBLEM 

WITH FirstLanguageID AS (
    SELECT language_id
    FROM film
    GROUP BY language_id
    ORDER BY language_id ASC
    LIMIT 1
)
SELECT name
FROM language
WHERE language_id = (SELECT language_id FROM FirstLanguageID);


--Select movie titles and replacement costs and ratings along with the average replacement cost for movies in the rating that the movie belongs to.

SELECT title ,replacement_cost , rating ,
ROUND(AVG(replacement_cost) OVER (PARTITION BY rating), 2 ) as average_replacement_cost
FROM film 
ORDER BY title;


---2nd appraoch for the same problem 

SELECT 
    f.title, 
    f.replacement_cost, 
    f.rating,
    avg_table.average_replacement_cost
FROM 
    film f
JOIN 
    (SELECT rating, ROUND(AVG(replacement_cost), 2) as average_replacement_cost
     FROM film
     GROUP BY rating) as avg_table
ON 
    f.rating = avg_table.rating
ORDER BY 
    f.title;

--Display each movie and the number of times it got rented.

SELECT inventory.film_id,COUNT(inventory.film_id)
FROM 
inventory 
JOIN rental 
ON inventory.inventory_id = rental.inventory_id 
GROUP BY inventory.film_id
ORDER BY inventory.film_id


--Show the number of movies each actor acted in.
SELECT 
    DISTINCT(actor.first_name || ' ' || actor.last_name) AS name, 
    COUNT(film_actor.film_id) AS film_count
FROM 
    actor
JOIN 
    film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY 
    actor.actor_id, actor.first_name, actor.last_name
ORDER BY 
    name
	
--Display the names of the actors that acted in more than 20 movies.	
	


SELECT name , film_count
FROM (SELECT 
	  DISTINCT(actor.first_name || ' ' || actor.last_name) AS name, 
	  COUNT(DISTINCT(film_actor.film_id)) AS film_count
      FROM 
      actor
      JOIN 
      film_actor ON actor.actor_id = film_actor.actor_id
      GROUP BY 
      actor.actor_id, actor.first_name, actor.last_name
      ORDER BY 
      name ASC)
WHERE film_count >= 20 ;

--How many actors have 8 letters only in their first_names.

SELECT COUNT(*)
FROM actor 
WHERE CHAR_LENGTH(first_name)=8;





--For all the movies rated “PG” show me the movie and the number of times it got rented.

SELECT 
    pg_films.film_id, 
    pg_films.title, 
    COUNT(rental.rental_id) AS rental_count
FROM 
    rental 
JOIN 
    (
        SELECT 
            film.film_id, 
            film.title, 
            film.rating, 
            inventory.inventory_id  
        FROM 
            film 
        JOIN 
            inventory ON film.film_id = inventory.film_id
        WHERE 
            film.rating = 'PG'
    ) AS pg_films ON pg_films.inventory_id = rental.inventory_id
GROUP BY 
    pg_films.film_id,
    pg_films.title
ORDER BY pg_films.film_id;





































SELECT COUNT(DISTINCT(first_name || last_name)) AS FUll_NAME
FROM actor;

-- identify duplicates 

SELECT first_name || ' ' || last_name AS full_name, COUNT(*) 
FROM actor
GROUP BY first_name, last_name
HAVING COUNT(*) > 1;

--Display the customer names that share the same address (e.g. husband and wife).

SELECT c1.first_name, c1.last_name, c2.first_name, c2.last_name
FROM customer c1
JOIN customer c2 
ON c1.customer_id <> c2.customer_id 
AND c1.address_id = c2.address_id;

--Display the total amount payed by all customers in the payment table.

SELECT SUM(amount)
From Payment;

-- Display the total amount payed by each customer in the payment table.
SELECT customer_id , SUM(amount)
FROM payment
GROUP BY customer_id
ORDER BY customer_id;

-- What is the highest total_payment done.
SELECT SUM(amount) AS total_payments
FROM payment
GROUP BY customer_id 
ORDER BY SUM(amount) DESC LIMIT 1 ;


--What is the name of the customer who made the highest total payments.

SELECT customer_id, first_name ,last_name 
FROM customer
WHERE customer_id IN (SELECT customer_id 
									FROM payment
									GROUP BY customer_id
									HAVING SUM(amount) = 
											(SELECT SUM(amount) AS total_payments
											FROM payment
											GROUP BY customer_id 
											ORDER BY SUM(amount) DESC LIMIT 1));

-- What is the movie(s) that was rented the most.
SELECT film_id ,title
FROM film WHERE film_id IN(
					SELECT film_id 
					FROM rental AS R JOIN inventory AS I 
					ON R.inventory_id = I.inventory_id 
					GROUP BY film_id 
					ORDER BY COUNT(film_id) DESC LIMIT 1) ;




---Which movies have been rented so far.

SELECT COUNT(title)
FROM film 
WHERE film_id  IN(
	
	SELECT DISTINCT(film_id) 
	FROM inventory AS I 
	JOIN rental AS R 
	ON I.inventory_id = R.inventory_id);
	
--Which movies have not been rented so far.

SELECT COUNT(title)
FROM film 
WHERE film_id NOT IN(
	
	SELECT DISTINCT(film_id) 
	FROM inventory AS I 
	JOIN rental AS R 
	ON I.inventory_id = R.inventory_id);

--Which customers have not rented any movies so far.


SELECT COUNT(DISTINCT(customer_id)) 
From customer
WHERE customer_id  NOT IN(
	SELECT customer_id
    FROM rental
);

--Display each movie and the number of times it got rented.

SELECT inventory.film_id, COUNT(inventory.film_id) FROM inventory
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY inventory.film_id
ORDER BY COUNT(inventory.film_id) DESC;
