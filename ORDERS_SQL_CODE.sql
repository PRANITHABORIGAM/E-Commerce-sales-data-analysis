 select * from df_orders

 --Find top 10 highest revenue generating products
 select top 10 product_id,sum(sale_price) as sales
 from df_orders
 group by product_id
 order by sales desc

--Find top 5 highest selling products in each region

with cte as (
select product_id,region,sum(sale_price) as sales
from df_orders
group by region,product_id),

cte1 as(
select * , row_number() over(partition by region order by sales desc) as rn
from cte)

select * from cte1
where rn <=5;

--Find month over month growth comparison for 2022 and 2023 sales

with cte as(
select year(order_date) as year, month(order_date) as month, sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
)

select month
,sum(case when year=2022 then sales else 0 end) as sales_2022
,sum(case when year=2023 then sales else 0 end) as sales_2023
from cte
group by month
order by month


--Find for each category which month had highest sales
with cte as(
select category,format(order_date,'yyyy-MM') as month,sum(sale_price) as sales
from df_orders
group by category,format(order_date,'yyyy-MM')
),
cte1 as(
select category,month,sales,ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte
)
select * from cte1
where rn=1


--which sub category had highest growth by profit in 2023 compare to 2022
with cte as(
select sub_category,year(order_date) as year,sum(profit) as tot
from df_orders
group by sub_category,year(order_date)
),
cte1 as(
select sub_category,
sum(case when year=2022 then tot else 0 end) as profit_2022,
sum(case when year=2023 then tot else 0 end) as profit_2023
from cte
group by sub_category
)
select * from(
select sub_category,
sum(case when profit_2023>profit_2022 then profit_2023 else 0 end) as hig
from cte1
group by sub_category 
) as rn
where hig !=0
order by hig desc


--which sub category had highest growth by sales in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022) AS sales_diff
from  cte2
order by (sales_2023-sales_2022) desc
