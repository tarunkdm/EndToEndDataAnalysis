--find top 10 highest reveue generating products 

select 
top 10
product_id,
sum(sale_price) as revenue
FROM retail_orders
group by product_id
order by sum(sale_price) desc



--find top 5 highest selling products in each region
with cte as
	(
	select 
	region,
	product_id,
	sum(sale_price) as revenue
	FROM retail_orders
	group by region, product_id
	)
	select region, product_id, revenue FROM
		(
		select
		*,
		ROW_NUMBER() OVER(partition by region order by revenue  desc) as rn
		from cte
		) AS Temp
		WHERE rn <= 5
		order by region, revenue desc


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
select 
DATEPART(month, order_date) As order_month,
SUM(CASE WHEN year(order_date) =2022 then sale_price else 0 END)  AS Sales_2022,
SUM(CASE WHEN year(order_date) =2023 then sale_price else 0 END) AS Sales_2023,
ROUND((SUM(CASE WHEN year(order_date) =2023 then sale_price else 0 END) - SUM(CASE WHEN year(order_date) =2022 then sale_price else 0 END))*100/SUM(CASE WHEN year(order_date) =2022 then sale_price else 0 END),2) as growth_percentage
	
FROM retail_orders WHERE Year(order_date) IN (2022,2023)
group by DATEPART(month, order_date)
order by DATEPART(month, order_date)


--for each category which month had highest sales 
with cte as
	(
	select 
	category, DATEPART(month, order_date) as order_month,DATEPART(year, order_date) as order_year,
	SUM(sale_price) as sales

	FROM retail_orders
	group by category, DATEPART(month, order_date), DATEPART(year, order_date)
	)
	select category, order_month, order_year FROM
		(
		select 
		category, order_month, order_year,sales,
		RANK() OVER(partition by category order by sales desc) as rnk
		FROM cte
		) as temp where rnk = 1



--which sub category had highest growth by profit in 2023 compare to 2022
with cte as 
		(
		select
		sub_category,
		SUM(case when year(order_date) =2022 then profit else 0 end) as profit_2022,
		SUM(case when year(order_date) =2023 then profit else 0 end) as profit_2023,
		(SUM(case when year(order_date) =2023 then profit else 0 end) - SUM(case when year(order_date) =2022 then profit else 0 end))*100/SUM(case when year(order_date) =2023 then profit else 0 end) as profit_growth

		from retail_orders
		group by sub_category
		)
		select sub_category, profit_2022, profit_2023, profit_growth FROM
			(
			select 
			*,
			rank() over(order by profit_growth desc) as rnk
			FROM cte
			) as temp where rnk = 1
