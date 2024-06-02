

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




--Display the movies offered for rent in store_id 1 and not offered in store_id 2

SELECT DISTINCT f.film_id, f.title
FROM film f
JOIN inventory i1 ON f.film_id = i1.film_id
LEFT JOIN inventory i2 ON f.film_id = i2.film_id AND i2.store_id = 2
WHERE i1.store_id = 1 AND i2.inventory_id IS NULL
ORDER BY f.film_id;


---Display the movies offered for rent in any of the two stores 1 and 2.

SELECT film_id 
FROM inventory
WHERE store_id =1 
UNION 
SELECT film_id 
FROM inventory
WHERE store_id = 2;

-- Display the movie titles of those movies offered in both stores at the same time.

SELECT f.film_id ,f.title 
FROM film f 
JOIN inventory i
ON f.film_id = i.film_id
WHERE i.store_id = 1
INTERSECT
SELECT f.film_id ,f.title 
FROM film f 
JOIN inventory i
ON f.film_id = i.film_id
WHERE i.store_id = 2

---Alternative method
SELECT DISTINCT f.film_id, f.title
FROM film f
JOIN inventory i1 ON f.film_id = i1.film_id
JOIN inventory i2 ON f.film_id = i2.film_id
WHERE i1.store_id = 1 AND i2.store_id = 2
ORDER BY f.film_id;


--- For each store, display the number of customers that are members of that store.
SELECT store_id , COUNT(customer_id)
FROM customer
GROUP BY store_id

-- Display the movie title for the most rented movie in the store with store_id 1


(SELECT b.film_id, b.store_id, b.title , COUNT(b.rental_id) AS rental_count
FROM (
    SELECT f.film_id, f.title, i.inventory_id, r.rental_id, c.store_id
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN customer c ON r.customer_id = c.customer_id
) AS b
WHERE b.store_id = 1
GROUP BY b.film_id, b.store_id,b.title
ORDER BY rental_count DESC LIMIT 1 );

--- How many movies are not offered for rent in the stores yet. There are two stores only 1 and 2.

SELECT 
    (SELECT COUNT(*) FROM film) - 
   
    (SELECT COUNT(DISTINCT i.film_id)
     FROM inventory i
     WHERE i.store_id IN (1, 2)) AS films_not_offered_for_rent;


--Display the customer_id’s for those customers that rented a movie DVD more than once


SELECT rental_id , rental_date , customer_id , film_id 
FROM rental JOIN inventory
ON rental.inventory_id = inventory.inventory_id;

WITH TEMP AS(
    SELECT rental_id , rental_date , customer_id , film_id 
	FROM rental JOIN inventory
	ON rental.inventory_id = inventory.inventory_id )
	
SELECT T1.customer_id ,count(T1.film_id)
FROM TEMP T1 join TEMP T2 
ON T1.customer_id = T2.customer_id AND T1.film_id = T2.film_id AND T1.rental_date <> T2.rental_date
GROUP BY T1.customer_id 
HAVING count(T1.film_id)> 1 ;














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
