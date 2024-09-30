use pizza_store;

/*Retrieve the total number of orders placed.*/
Select count(distinct order_id)
from orders; 

/* total pizzas sold*/
Select sum(quantity)
from order_details;

/*Calculate the total revenue generated from pizza sales.*/
select sum(od.quantity * p.price) REVENUE_GENERATED
from orders o, order_details od, pizzas p
where o.order_id=od.order_id and
od.pizza_id= p.pizza_id;

/*Calculate average order value*/
select ((sum(od.quantity * p.price))/count(distinct(o.order_id))) "Average Order Value"
from orders o, order_details od, pizzas p
where o.order_id=od.order_id and
od.pizza_id= p.pizza_id;

/*Identify the highest-priced pizza.*/
select p2.name 'Highest Priced Pizza' , p2.category,p1.price 'Price'
from pizzas p1, pizza_types p2
where p1.pizza_type_id = p2.pizza_type_id
and p1.price = (select max(price)
from pizzas);

select p2.name , p2.category, p1.price
from pizzas p1, pizza_types p2
where p1.pizza_type_id = p2.pizza_type_id
order by price desc
limit 1;

/* Identify the most common pizza size ordered.*/
select size 'most ordered size' ,count(*),dense_rank() over (order by count(*) desc) 'Rank'
from order_details od, pizzas p
where od.pizza_id = p.pizza_id
group by size
limit 1;

/*List the top 5 most ordered pizza types along with their quantities.*/
select  pt.name 'The 5 most ordered Pizza types', sum(od.quantity) 'Quantities'
from order_details od, pizzas p,pizza_types pt
where od.pizza_id = p.pizza_id
and p.pizza_type_id = pt.pizza_type_id
group by name 
order by sum(od.quantity) desc
limit 5;

/*Join the necessary tables to find the total quantity of each pizza category ordered.*/
select  category 'Pizza Category' , sum(quantity) 'Total Quantity'
from pizza_types pt , pizzas p, order_details od
where od.pizza_id = p.pizza_id
and p.pizza_type_id = pt.pizza_type_id
group by category;

/*Determine the distribution of orders by hour of the day.*/
select hour(time) 'Hour of the day' , count(*) 'No. of Orders recieved'
from orders
group by hour(time)
order by count(*) desc;

/*Group the orders by date and calculate the average number of pizzas ordered per day.*/
SELECT round(avg(quantity), 0) as avg_pizza_ordered_per_day 
FROM 
(SELECT orders.date, SUM(order_details.quantity) AS quantity
FROM orders JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY 1) AS order_quantity;

/*Determine the top 3 most ordered pizza types based on revenue.*/
SELECT 
    pizza_types.name AS pizza_name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

/*Calculate the percentage contribution of each pizza type to total revenue*/
select a.pizza_type_id , a.rev as revenue_generated,cast(((a.rev/b.total_rev)*100) as decimal(10,2)) as pct_revenue_generated
from (Select p.pizza_type_id, sum(od.quantity*p.price) rev
from pizzas p, order_details od, orders o 
where o.order_id = od.order_id
and od.pizza_id = p.pizza_id  
group by p.pizza_type_id) a ,  (select sum(od.quantity * p.price) total_rev
from orders o, order_details od, pizzas p
where o.order_id=od.order_id and
od.pizza_id= p.pizza_id
) b;
