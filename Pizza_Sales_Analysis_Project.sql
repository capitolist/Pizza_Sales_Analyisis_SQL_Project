create database pizzahut:
create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);
create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);
-- import pizzas and pizza_types manually by data import wizard


-- 1 Retrieve the total number of orders placed.
select count(orders.order_id) as total_orders 
from orders;
-- 2 Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity*pizzas.price),2) as revenue
from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id;
-- 3 Identify the highest-priced pizza.
select pizza_types.name,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
order by pizzas.price desc limit 1;

-- 4 retrieve the most common quantity ordered 
select order_details.quantity,count(order_details.order_details_id) 
from order_details group by quantity  limit 1;


-- 5 Identify the most common pizza size ordered.
select pizzas.size,count(order_details.order_details_id) as order_count
from order_details join pizzas 
on order_details.pizza_id=pizzas.pizza_id
group by size 
order by order_count 
desc limit 1;
-- 6 List the top 5 most ordered pizza types along with their quantities.
select pizzas.pizza_type_id,count(order_details.quantity) as pizza_type_count
from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.pizza_type_id
order by pizza_type_count 
desc limit 5;

-- 7 Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category , sum(order_details.quantity) quantity
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by quantity desc;

-- 8 Determine the distribution of orders by hour of the day.
select hour(orders.order_time) as hour,count(orders.order_id) from orders
group by hour(orders.order_time) order by hour asc;

-- 9 Join relevant tables to find the category-wise distribution of pizzas.
select category , count(name) from pizza_types 
group by category;

-- 10 Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),2) 
from ( select orders.order_date , sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date ) as order_quantity;

-- 11 Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name , sum(pizzas.price*order_details.quantity) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name 
order by revenue desc limit 3;

-- 12 Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round((sum(pizzas.price*order_details.quantity)/(select sum(pizzas.price*order_details.quantity) 
										  from pizza_types join pizzas
										  on pizza_types.pizza_type_id=pizzas.pizza_type_id
											join order_details
											 on order_details.pizza_id=pizzas.pizza_id))*100,2) as share_percent
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id 
group by pizza_types.category;


-- 13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name ,revenue 
from (select category ,name,revenue ,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category, pizza_types.name
order by revenue ) as a) as b
where rn<=3;

-- 14 Analyze the cumulative revenue generated over time.
select order_date , sum(revenue) over(order by order_date ) as cum_revenue3
from 
(select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue
from order_details join orders
on order_details.order_id = orders.order_id
join pizzas 
on pizzas.pizza_id=order_details.pizza_id
group by orders.order_date) as sales




