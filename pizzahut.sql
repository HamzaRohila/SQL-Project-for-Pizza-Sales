


CREATE TABLE orders(
Order_id int not null primary key,
Order_date date not null,
Order_time TIME not null
);

CREATE TABLE order_det(
	order_det_id int not null,
    order_id int not null,
    pizza_id text not null,
    quant int not null
    );
ALTER TABLE order_det
ADD PRIMARY KEY (order_det_id);



-- TOTAL NUMBER OF ORDERS PLACED
SELECT count(order_id) FROM pizzahut.orders;
-- 21350


-- TOTAL SALES GENERATED 
SELECT 
    ROUND(SUM(pizzas.price * order_det.quant),2) AS Revenue
FROM
    Order_det
        JOIN
    pizzas ON order_det.pizza_id = pizzas.pizza_id;
    

-- HIGHEST PRICED PIZZA ALONG WITH NAME AND INGREDIENTS
SELECT 
    pizza_types.name , pizzas.price, pizza_types.ingredients
FROM
    pizza_types
        JOIN
    pizzas 
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 4;


--  IDENTIFY MOST COMMOM PIZZA SIZE OFFERED
SELECT 
    pizzas.size, COUNT(order_det.order_det_id) details
FROM
    order_det
        JOIN
    pizzas 
	ON order_det.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY details DESC
LIMIT 1;


-- TOP 5 MOST ORDERED PIZZA TYPES WITH THEIR QUANTITIES 
use pizzahut;
SELECT 
    pizza_types.name, SUM(order_det.quant) quant
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_det ON pizzas.pizza_id = order_det.pizza_id
GROUP BY pizza_types.name
ORDER BY quant DESC
LIMIT 5;


-- JOIN NECESSARY TABLES TO FIND TOTAL QUANTITY OF EACH PIZZA CATEGORY ORDERED 

SELECT 
    pizza_types.category, SUM(order_det.quant) AS Quantity_Ordered
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_det ON pizzas.pizza_id = order_det.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity_Ordered DESC;



-- DISTRIBUTION OF ORDERS ON THE BASIS OF HOURS OF THE DAY

SELECT 
    HOUR(order_time) Hrs_distribution, COUNT(order_id)
FROM
    orders
GROUP BY Hrs_distribution
ORDER BY COUNT(order_id) DESC;

-- CATEGORY-WISE DISTRIBUTION OF PIZZAS
SELECT 
    pizza_types.category,
    COUNT(pizza_types.pizza_type_id),
    GROUP_CONCAT(pizza_types.name)
FROM
    pizza_types
GROUP BY pizza_types.category;


-- GROUP THE ORDERS BY DATE AND CALCULATE THE AVERAGE NUMBER OF PIZZAS ORDERED PER DAY 
SELECT 
    ROUND(AVG(no_of_pizzas), 0)
FROM
    (SELECT 
        orders.order_date,
            COUNT(orders.order_id) orders_placed,
            SUM(order_det.quant) no_of_pizzas
    FROM
        Orders
    JOIN order_det ON order_det.order_id = orders.order_id
    GROUP BY orders.order_date) AS quantity;
    
    
    
-- DETERMINE TOP 3 MOST ORDERED PIZZAS TYPES BASED ON REVENUE


SELECT 
    pizza_types.name,
    ROUND(SUM(order_det.quant * pizzas.price), 1) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_det ON pizzas.pizza_id = order_det.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;









-- CALCULATE THE PERCENTAGE CONTRIBUTION OF EACH PIZZA TYPE TO TOTAL REVENUE 

SELECT 
    pizza_types.category,
   CONCAT( ROUND(SUM(order_det.quant * pizzas.price) / (SELECT 
            SUM(order_det.quant * pizzas.price)
        FROM
            order_det
                JOIN
            pizzas ON order_det.pizza_id = pizzas.pizza_id)* 100,1),'%') AS REV
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    Order_det ON pizzas.pizza_id = order_det.pizza_id
GROUP BY pizza_types.category;


-- ANALYZE CUMULATIVE REVENUE GENERATED OVER TIME
SELECT
	order_date, 
	SUM(revenue) OVER (order by order_date) AS Cumu_rev
FROM 
	(SELECT 
		orders.order_date,
		ROUND(SUM(order_det.quant * pizzas.price), 0) revenue
	FROM
		order_det
			JOIN
		pizzas ON order_det.pizza_id = pizzas.pizza_id
			JOIN
		orders ON orders.order_id = order_det.order_id
	GROUP BY orders.order_date
	ORDER BY orders.order_date) as Tot_rev;



-- DETERMINE THE TOP 3 MOST ORDERED PIZZA TYPES BASED ON REVENUE ON EACH PIZZA CATEGORY

SELECT 
	category, name, rev 
FROM
	(SELECT
		category, name, rev,
		RANK() OVER (PARTITION BY category ORDER BY rev DESC) AS rn
	FROM 
		(SELECT 
			pizza_types.category,pizza_types.name, round(sum(order_det.quant*pizzas.price),0) as rev
		FROM 
			pizzas
				JOIN
				pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id
					JOIN 
					order_det
					ON pizzas.pizza_id=order_det.pizza_id
		GROUP BY pizza_types.category,pizza_types.name) AS a) AS b
WHERE rn<=3;







	

