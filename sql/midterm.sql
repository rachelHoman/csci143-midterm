/* PROBLEM 1:
 *
 * The Office of Foreign Assets Control (OFAC) is the portion of the US government that enforces international sanctions.
 * OFAC is conducting an investigation of the Pagila company to see if you are complying with sanctions against North Korea.
 * Current sanctions limit the amount of money that can be transferred into or out of North Korea to $5000 per year.
 * (You don't have to read the official sanctions documents, but they're available online at <https://home.treasury.gov/policy-issues/financial-sanctions/sanctions-programs-and-country-information/north-korea-sanctions>.)
 * You have been assigned to assist the OFAC auditors.
 *
 * Write a SQL query that:
 * Computes the total revenue from customers in North Korea.
 *
 * NOTE:
 * All payments in the pagila database occurred in 2022,
 * so there is no need to do a breakdown of revenue per year.
 */

SELECT SUM(p.amount) AS total_revenue
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'North Korea';




/* PROBLEM 2:
 *
 * Management wants to hire a family-friendly actor to do a commercial,
 * and so they want to know which family-friendly actors generate the most revenue.
 *
 * Write a SQL query that:
 * Lists the first and last names of all actors who have appeared in movies in the "Family" category,
 * but that have never appeared in movies in the "Horror" category.
 * For each actor, you should also list the total amount that customers have paid to rent films that the actor has been in.
 * Order the results so that actors generating the most revenue are at the top.
 */

SELECT 
    a.first_name, 
    a.last_name, 
    COALESCE(SUM(p.amount), 0) AS total_revenue
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film_category fc_family ON fa.film_id = fc_family.film_id
JOIN category c_family ON fc_family.category_id = c_family.category_id
LEFT JOIN 
    (
        SELECT 
            f.film_id, 
            p.amount
        FROM film f
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        JOIN payment p ON r.rental_id = p.rental_id
    ) p ON fa.film_id = p.film_id
WHERE c_family.name = 'Family'
    AND a.actor_id NOT IN (
        SELECT a.actor_id
        FROM actor a
        JOIN film_actor fa_horror ON a.actor_id = fa_horror.actor_id
        JOIN film_category fc_horror ON fa_horror.film_id = fc_horror.film_id
        JOIN category c_horror ON fc_horror.category_id = c_horror.category_id
        WHERE c_horror.name = 'Horror'
    )
GROUP BY 
    a.actor_id, 
    a.first_name, 
    a.last_name
ORDER BY total_revenue DESC;





/* PROBLEM 3:
 *
 * You love the acting in AGENT TRUMAN, but you hate the actor RUSSELL BACALL.
 *
 * Write a SQL query that lists all of the actors who starred in AGENT TRUMAN
 * but have never co-starred with RUSSEL BACALL in any movie.
 */

SELECT DISTINCT a.actor_id, a.first_name, a.last_name
FROM actor a
JOIN film_actor fa1 ON a.actor_id = fa1.actor_id
JOIN film f1 ON fa1.film_id = f1.film_id
JOIN film_actor fa2 ON f1.film_id = fa2.film_id
JOIN actor a2 ON fa2.actor_id = a2.actor_id
WHERE f1.title = 'AGENT TRUMAN' 
  AND NOT EXISTS (
    SELECT 1
    FROM film_actor fa3
    JOIN film f3 ON fa3.film_id = f3.film_id
    WHERE fa3.actor_id = a.actor_id
      AND f3.film_id IN (
        SELECT f4.film_id
        FROM film_actor fa4
        JOIN actor a3 ON fa4.actor_id = a3.actor_id
        JOIN film f4 ON fa4.film_id = f4.film_id
        WHERE a3.first_name = 'RUSSELL' AND a3.last_name = 'BACALL'
      )
  );





/* PROBLEM 4:
 *
 * You want to watch a movie tonight.
 * But you're superstitious,
 * and don't want anything to do with the letter 'F'.
 * List the titles of all movies that:
 * 1) do not have the letter 'F' in their title,
 * 2) have no actors with the letter 'F' in their names (first or last),
 * 3) have never been rented by a customer with the letter 'F' in their names (first or last).
 *
 * NOTE:
 * Your results should not contain any duplicate titles.
 */

SELECT DISTINCT f.title
FROM film f
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
LEFT JOIN actor a ON fa.actor_id = a.actor_id
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN customer c ON r.customer_id = c.customer_id
WHERE f.title NOT LIKE '%F%'
  AND a.first_name NOT LIKE '%f%' AND a.last_name NOT LIKE '%f%'
  AND (c.first_name IS NULL OR c.first_name NOT LIKE '%f%')
  AND (c.last_name IS NULL OR c.last_name NOT LIKE '%f%');




