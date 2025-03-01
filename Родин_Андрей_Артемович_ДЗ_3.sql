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


2.1
select job_industry_category as Сфера_деятельности,
       count(customer_id) as Количество_клиентов
from customer c 
group by Сфера_деятельности
order by Количество_клиентов;

2.2
select c.job_industry_category as Сфера_деятельности,
	   extract (month from t.transaction_date::timestamp) as Месяц,
	   sum(t.list_price) as Сумма_транзакций
from customer c 
join transaction t on c.customer_id = t.customer_id
group by Месяц, Сфера_деятельности
order by Месяц, Сфера_деятельности;

2.3
select t.brand as Бренд,
       count(t.transaction_id) as Количество_онлайн_заказов
from transaction t 
left join customer c on t.customer_id = c.customer_id
where t.online_order = true and t.order_status = 'Approved' and c.job_industry_category = 'IT'
group by t.brand
order by Бренд;

2.4.1
select customer_id,
       sum(list_price) as Сумма_всех_транзакций,
       max(list_price) as Максимальная_сумма_транзакции,
       min(list_price) as Минимальная_сумма_транзакции,
       count(transaction_id) as Количество_транзакций
from transaction
group by customer_id
order by Сумма_всех_транзакций desc, Количество_транзакций desc;

2.4.2
select customer_id,
       sum(list_price) over (partition by customer_id) as Сумма_всех_транзакций,
       max(list_price) over (partition by customer_id) as Максимальная_сумма_транзакции,
       min(list_price) over (partition by customer_id) as Минимальная_сумма_транзакции,
       count(transaction_id) over (partition by customer_id) as Количество_транзакций
from transaction
order by Сумма_всех_транзакций desc, Количество_транзакций desc;

2.5.1
select c.first_name,
       c.last_name
from transaction t
left join customer c on t.customer_id = c.customer_id
where t.list_price = (select min(t.list_price) 
                      from transaction t 
                      left join customer c on c.customer_id = t.customer_id
                      where t.list_price is not null);

2.5.2
select c.first_name,
       c.last_name
from transaction t
left join customer c on t.customer_id = c.customer_id
where t.list_price = (select max(t.list_price) 
                      from transaction t 
                      left join customer c on c.customer_id = t.customer_id);

2.6
select customer_id,
       transaction_date,
       list_price
from (select customer_id,
             transaction_date,
             list_price,
             row_number() over (partition by customer_id order by transaction_date) as rn
      from transaction) AS ranked_transactions
where rn = 1;

2.7
with TransactionIntervals as (select t.customer_id,
                                     t.transaction_date,
                                     lag(t.transaction_date) over (partition by t.customer_id order by t.transaction_date) as prev_transaction_date,
                                     (t.transaction_date - lag(t.transaction_date) over (partition by t.customer_id order by t.transaction_date)) as interval_days
                              from transaction t),
MaxIntervals as (select customer_id,
                        max(interval_days) as max_interval_days
                 from TransactionIntervals
                 group by customer_id)
select c.first_name,
       c.last_name,
       c.job_title,
       mi.max_interval_days
from customer c
join MaxIntervals mi on c.customer_id = mi.customer_id
where mi.max_interval_days is not null
order by mi.max_interval_days desc;