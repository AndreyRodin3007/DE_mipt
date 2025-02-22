create table customer (
	customer_id int,
	first_name text,
	last_name text,
	gender varchar(20),
	DOB timestamp,
	job_title text,
	job_industry_category text,
	wealth_segment text,
	deceased_indicator varchar(20),
	owns_car varchar(10),
	address	text,
	postcode int,
	state text,
	country	text,
	property_valuation int
);


create table transaction (
	transaction_id int,
	product_id int,
	customer_id int,
	transaction_date timestamp,
	online_order bool,
	order_status text,
	brand text,
	product_line text,
	product_class text,
	product_size text,
	list_price float8,
	standard_cost float8
);


1.

select distinct brand
from transaction 
where standard_cost > 1500;

2.

select *
from transaction
where order_status = 'Approved' and transaction_date::date between '2017-04-01' and '2017-04-09';

3.

select distinct job_title
from customer
where (job_industry_category = 'IT' or job_industry_category = 'Financial Services') and job_title like 'Senior%';

4.

select distinct brand
from transaction t
left join customer c on t.customer_id = c.customer_id 
where c.job_industry_category = 'Financial Services';

5.

select c.customer_id, c.first_name, c.last_name
from customer c
left join transaction t on c.customer_id = t.customer_id
where t.online_order = true and (t.brand = 'Giant Bicycles' or t.brand = 'Norco Bicycles' or t.brand = 'Trek Bicycles')
limit 10;

6.

SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id NOT IN (SELECT customer_id FROM transaction);

7.

select c.customer_id, c.first_name, c.last_name
from customer c
left join transaction t on c.customer_id = t.customer_id
where c.job_industry_category = 'IT' and standard_cost = (select max(standard_cost) from transaction);

8.

select c.customer_id, c.first_name, c.last_name
from customer c
left join transaction t on c.customer_id = t.customer_id
where (c.job_industry_category = 'IT' or c.job_industry_category = 'Health') and t.order_status = 'Approved' and t.transaction_date::date between '2017-07-07' and '2017-07-17';