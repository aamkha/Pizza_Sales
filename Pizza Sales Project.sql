Create Database Pizzahut;

Use pizzahut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Retrieve the total number of orders placed. --

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales. --

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- Identify the highest-priced pizza. --

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    order by pizzas.price desc limit 1;

-- Identify the most common pizza size ordered. --

SELECT 
    pizzas.size, COUNT(order_details.quantity) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count desc
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities. --

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS Total_Quantities
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_Quantities DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered. --

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Total_Quantities
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_Quantities DESC;

-- Determine the distribution of orders by hour of the day. -- 

SELECT 
    HOUR(order_time) AS hours, COUNT(order_id)
FROM
    orders
GROUP BY hours;

-- Join relevant tables to find the category-wise distribution of pizzas. --

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day. --

SELECT 
    ROUND(AVG(quantity), 0) AS Average_Order_Per_Day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue. --

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue. --

SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
            2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-- Analyze the cumulative revenue generated over time. --

SELECT 
    order_date, sum(Revenue) over(order by order_date) cum_revenue
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity*pizzas.price) AS Revenue	
    FROM
        order_details
    JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id join orders
    on orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS Cumulative;
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category. --

Select name, round(revenue,2) from
(Select category, name, revenue, rank() over(partition by category order by revenue desc) as rn from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM((order_details.quantity) * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as A) as b 
 where rn<=3;

