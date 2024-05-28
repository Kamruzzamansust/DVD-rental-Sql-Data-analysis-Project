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

--


