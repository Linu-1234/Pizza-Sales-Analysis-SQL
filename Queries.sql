-- Basic Questions

/* 1.Retrieve the total number of orders placed. */

select count(order_id) as total_orders from orders;

/* 2.Calculate the total revenue generated from pizza sales. */

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
/* 3.Identify the highest-priced pizza. */

-- method 1

SELECT 
    pizzas.pizza_type_id,
    pizza_types.name,
    pizzas.size,
    pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
WHERE
    price IN (SELECT 
            MAX(price)
        FROM
            pizzas);

-- method 2

SELECT 
    pizzas.pizza_type_id,
    pizza_types.name,
    pizzas.size,
    pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

/* 4.Identify the most common pizza size ordered. */

SELECT 
    pizzas.size, SUM(order_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY quantity DESC
LIMIT 1;

/* 5.List the top 5 most ordered pizza types along with their quantities.*/

SELECT 
    pizza_types.pizza_type_id,
    pizza_types.name,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 5;



-- Intermediate questions

/* 1.Join the necessary tables to find the total quantity of each pizza category ordered. */

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1;

/* 2.Determine the distribution of orders by hour of the day. */

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour
ORDER BY hour ASC; 

/* 3.Join relevant tables to find the category-wise distribution of pizzas. */

SELECT 
    pizza_types.category, COUNT(order_details.order_id) AS count
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY count DESC;

/* 4.Group the orders by date and calculate the average number of pizzas ordered per day. */

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
    ORDER BY quantity DESC) AS order_quantity;
    
/* 5.Determine the top 3 most ordered pizza types based on revenue. */

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;



-- Advanced questions

/* 1.Calculate the percentage contribution of each pizza type to total revenue. */

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_revenue
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

/* 2.Analyze the cumulative revenue generated over time. */

SELECT 
	order_date, 
    sum(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM
	(SELECT 
		orders.order_date,
		SUM(order_details.quantity * pizzas.price) AS revenue
	FROM
		order_details
			JOIN
		pizzas ON order_details.pizza_id = pizzas.pizza_id
			JOIN
		orders ON orders.order_id = order_details.order_id
	GROUP BY 1) 
AS sales ;

/* 3.Determine the top 3 most ordered pizza types based on revenue for each pizza category. */

SELECT 
	category, 
    name,
    revenue
FROM
	(SELECT category,name,revenue,RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS ranks 
	FROM
		(SELECT 
			pizza_types.category,
			pizza_types.name,
			SUM(order_details.quantity * pizzas.price) AS revenue
		FROM
			pizza_types
				JOIN
			pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
				JOIN
			order_details ON order_details.pizza_id = pizzas.pizza_id
		GROUP BY 1 , 2
		ORDER BY 1 ASC , 3 DESC) 
		AS A )
	AS B
WHERE ranks <=3;

