/*
Do we have actors in the actor table that share the full name and if yes display those shared names
*/


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
