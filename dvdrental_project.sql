

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




---Select the ratings and average replacement cost for Italian movies.

SELECT  film.rating, ROUND(AVG(film.replacement_cost),2) AS average_replacement_cost
FROM film
JOIN language ON film.language_id = language.language_id
WHERE language.name = 'Italian'
GROUP BY film.rating;

---Count the movies that has the maximum replacement_cost in the film table.

SELECT COUNT(film_id)
FROM film
WHERE replacement_cost = 

(SELECT MAX(replacement_cost)
FROM film)

--Count the number of movies we have for each language in the film table. (Note we have movies that are in English and Italian languages only).


SELECT language.name ,COUNT(*)
FROM film 
JOIN language
ON film.language_id = language.language_id
where language.name IN('English','Italian')
GROUP BY  language.name ;



---Count the number of movies exist under each of the 6 languages that exisit in the language table (English, Italian, French, Mandarine, Japanese and German).

SELECT language.name, COALESCE(movie_count, 0) AS movie_count
FROM language
LEFT JOIN (
    SELECT language_id, COUNT(*) AS movie_count
    FROM film
    GROUP BY language_id
) AS film_counts ON language.language_id = film_counts.language_id
WHERE language.name IN ('English', 'Italian', 'French', 'Mandarin', 'German', 'Japanese');


--- Select the language_id, rating and count the number of movies under each language_id and rollup on language_id and rating then sort by the language id.

SELECT
    COALESCE(CAST(language_id AS TEXT), 'Total') AS language_id,
    COALESCE(CAST(rating AS TEXT), 'Total') AS rating,
    COUNT(*) AS count
FROM film
GROUP BY ROLLUP (language_id, rating)
ORDER BY language_id, rating;

-- Select movie titles, rental_rates along with a new column that has the rental rate discounted 20%
SELECT title , rental_rate , ROUND(rental_rate *.80,2)  AS discounted_rental_rate 
FROM film;



--Select title, replacement_cost, rating, along with the maximum replacement cost under that rating.


SELECT
    f.title,
    f.replacement_cost,
    f.rating
FROM
    film f
JOIN (
    SELECT
        rating,
        MAX(replacement_cost) AS max_replacement_cost
    FROM
        film
    GROUP BY
        rating
) AS sub
ON f.rating = sub.rating AND f.replacement_cost = sub.max_replacement_cost
ORDER BY
    f.rating;




/* What is a Window Function?
A window function performs a calculation across a set of table rows that are 
somehow related to the current row. Unlike aggregate functions, which return a single value 
for a group of rows, a window function returns a value for each row in the table.
*/

/* Basic Syntax for window function 
function_name(expression) OVER (
    [PARTITION BY column_list]
    [ORDER BY column_list]
    [frame_clause]
)
*/

/*
Common Window Functions
ROW_NUMBER(): Assigns a unique number to each row within the partition of a result set.
RANK(): Assigns a rank to each row within the partition of a result set, with gaps in the ranking values.
DENSE_RANK(): Similar to RANK(), but without gaps.
SUM(): Calculates the sum of a set of values.
AVG(): Calculates the average of a set of values.
LEAD and LAG Functions
LEAD(): Provides access to a subsequent row in the result set without the use of a self-join.
LAG(): Provides access to a previous row in the result set without the use of a self-join.
*/

/*
LEAD(expression, offset, default) OVER (
    [PARTITION BY column_list]
    [ORDER BY column_list]
)

LAG(expression, offset, default) OVER (
    [PARTITION BY column_list]
    [ORDER BY column_list]
)
*/

---Group the rows in the film table into 4 buckets or 4 order groups.

SELECT group_number,COUNT(*)
FROM 
(SELECT
    title,
    replacement_cost,
    rating,
    NTILE(4) OVER (
		PARTITION BY rating 
		ORDER BY replacement_cost 
		DESC) AS group_number
FROM
    film) temp
GROUP BY group_number
ORDER BY 1 ;

---Select for each movie it’s title, rental_rate and the rental_rate for the next two rows partitioned by the language_id.

SELECT title , rental_rate ,
LEAD(rental_rate ,2) OVER ( PARTITION BY language_id)
FROM film;


--Select for each movie it’s title, rental_rate and the rental_rate for the two previous rows partitioned by the language_id

SELECT title , rental_rate ,
LAG(rental_rate,2) OVER (PARTITION BY language_id)
FROM film;


--Show the rank by rating and order the results by rental_rate.
SELECT title , language_id , rental_rate , rating,
RANK() OVER (PARTITION BY rating ORDER BY rental_rate DESC)
FROM film;


--Show the percentage rank by rating and order the results by replacement_cost

SELECT title , replacement_cost , rating,
PERCENT_RANK() OVER (PARTITION BY rating ORDER BY replacement_cost DESC)
FROM film;


--Create “temp_table” table with the WITH statement that has all the movies with titles that start with a ‘b’ or ‘B’. Then select all information from the “temp_table
WITH temp_table AS(
SELECT title 
FROM film
WHERE title ILIKE 'B%'
)
SELECT * FROM temp_table;


---Select all the movies excluding those under ‘PG-13’ or ‘G’ rating

SELECT * FROM film 
WHERE rating NOT IN ('PG-13','G');


---Select the actors with actor_id from 1 to 20.

SELECT * FROM actor 
WHERE actor_id BETWEEN 1 AND 20;

--Select language_ids and language names that have movies in the film table with those language_ids.
SELECT
    l.language_id,
    l.name AS language_name
FROM
    language l
INNER JOIN
    film f ON l.language_id = f.language_id
GROUP BY
    l.language_id, l.name;

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


--identify the top 10 customers who have rented movies
SELECT 
     c.customer_id,
     CONCAT(c.first_name , ' ' , c.last_name) AS customer_name,
	 COUNT(r.rental_id) AS total_rents
FROM customer AS c 
JOIN rental r 
ON c.customer_id = r.customer_id
GROUP BY c.customer_id , customer_name
ORDER BY total_rents DESC
LIMIT 10;



--identify the top 5 popular movies,

SELECT f.film_id,f.title,COUNT(*)
FROM film AS f
JOIN inventory as i 
ON f.film_id = i.film_id
join rental AS r 
on i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY COUNT(*) DESC
LIMIT 10;

--What is the average number of rental per customer

SELECT ROUND(COUNT(rental_id))/COUNT(DISTINCT customer_id) AS Average_num_of_rentals
From rental 


--which genres are most frequently rented

SELECT ca.name, COUNT(r.rental_id)
FROM film_category as fc 
LEFT JOIN category as ca 
ON fc.category_id = ca.category_id
LEFT JOIN film AS f
ON fc.film_id = f.film_id
LEFT JOIN inventory AS i
ON f.film_id = i.film_id
LEFT JOIN rental AS r 
ON i.inventory_id = r.inventory_id
GROUP BY ca.name
ORDER BY  COUNT(r.rental_id) DESC;


-- identify peak and off-peak rental times

SELECT 
TO_CHAR(rental_date,'Day') AS day_of_week,
EXTRACT(HOUR FROM rental_date) AS hour,
COUNT(rental_id) AS rental_count
FROM rental
GROUP BY day_of_week ,hour
ORDER BY day_of_week ;


-- For each week day how many movies  rented 

SELECT 
  day_of_week,
  SUM(rental_count) AS total_rentals
FROM (
  SELECT
    TO_CHAR(rental_date, 'Day') AS day_of_week,
    EXTRACT(HOUR FROM rental_date) AS hour,
    COUNT(rental_id) AS rental_count
  FROM rental
  GROUP BY TO_CHAR(rental_date, 'Day'), EXTRACT(HOUR FROM rental_date)
) AS daily_rentals
GROUP BY day_of_week
ORDER BY day_of_week;



--order it by weekdays

SELECT 
  day_of_week,
  SUM(rental_count) AS total_rentals
FROM (
  SELECT
    TRIM(TO_CHAR(rental_date, 'Day')) AS day_of_week,
    EXTRACT(HOUR FROM rental_date) AS hour,
    COUNT(rental_id) AS rental_count
  FROM rental
  GROUP BY TRIM(TO_CHAR(rental_date, 'Day')), EXTRACT(HOUR FROM rental_date)
) AS daily_rentals
GROUP BY day_of_week
ORDER BY 
  CASE 
    WHEN day_of_week = 'Sunday' THEN 1
    WHEN day_of_week = 'Monday' THEN 2
    WHEN day_of_week = 'Tuesday' THEN 3
    WHEN day_of_week = 'Wednesday' THEN 4
    WHEN day_of_week = 'Thursday' THEN 5
    WHEN day_of_week = 'Friday' THEN 6
    WHEN day_of_week = 'Saturday' THEN 7
  END;


--identify the customer who returns dvd late 


WITH rental_status AS (
  SELECT 
    r.customer_id, 
    r.rental_date, 
    r.return_date,
    f.rental_duration, 
    (r.return_date - r.rental_date) AS date_difference,
    CASE 
      WHEN (r.return_date - r.rental_date) > (f.rental_duration * interval '1 day') THEN 'Late Return'
      ELSE 'On Time'
    END AS return_status
  FROM rental AS r
  JOIN customer AS c 
    ON r.customer_id = c.customer_id
  JOIN inventory AS i 
    ON i.inventory_id = r.inventory_id
  JOIN film AS f 
    ON i.film_id = f.film_id
)
SELECT 
  customer_id, 
  COUNT(*) AS late_return_count
FROM rental_status
WHERE return_status = 'Late Return'
GROUP BY customer_id
ORDER BY late_return_count DESC;

---identify the cuistomer who returns on time


WITH rental_status AS (
  SELECT 
    r.customer_id, 
    r.rental_date, 
    r.return_date,
    f.rental_duration, 
    (r.return_date - r.rental_date) AS date_difference,
    CASE 
      WHEN (r.return_date - r.rental_date) > (f.rental_duration * interval '1 day') THEN 'Late Return'
      ELSE 'On Time'
    END AS return_status
  FROM rental AS r
  JOIN customer AS c 
    ON r.customer_id = c.customer_id
  JOIN inventory AS i 
    ON i.inventory_id = r.inventory_id
  JOIN film AS f 
    ON i.film_id = f.film_id
)
SELECT 
  customer_id, 
  COUNT(*) AS total_return_count,
  COUNT(CASE WHEN return_status = 'Late Return' THEN 1 END) AS late_return_count
FROM rental_status
GROUP BY customer_id
ORDER BY late_return_count DESC;



--How many rented films were returned late, early and on time

WITH t1 AS (
  SELECT *, 
         (return_date - rental_date) AS date_difference
  FROM rental
),
t2 AS (
  SELECT 
    f.rental_duration, 
    t1.date_difference,
    CASE 
      WHEN f.rental_duration > EXTRACT(day FROM t1.date_difference) THEN 'Returned Early'
      WHEN f.rental_duration = EXTRACT(day FROM t1.date_difference) THEN 'Returned On Time'
      ELSE 'Returned Late'
    END AS return_status
  FROM film f 
  JOIN inventory i USING(film_id)
  JOIN t1 USING(inventory_id)
)
SELECT return_status, COUNT(*) AS total_no_of_films
FROM t2
GROUP BY return_status
ORDER BY total_no_of_films DESC;








