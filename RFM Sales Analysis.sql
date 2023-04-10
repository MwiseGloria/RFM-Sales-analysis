
----Inspecting data

select*
from Sales_analysis

---checking unique values

select distinct status from Sales_analysis---- plot
select distinct year_id from Sales_analysis
select distinct PRODUCTLINE  from Sales_analysis ---plot
select distinct country  from Sales_analysis ----plot
select distinct dealsize from Sales_analysis ---plot
select distinct territory from Sales_analysis-----plot


----Some analysis

--group sales by productline

select productline, sum(sales) as Revenue
from Sales_analysis
group by productline
order by 2 desc

----year with most sales 

select year_id, sum(sales) as Revenue
from Sales_analysis
group by year_id
order by 2 desc


--- whay is 2005 the year with least sales? how many month operated in 2005? compared to 2004?
--2005
select distinct month_id from Sales_analysis
where year_id = 2005
---2004
select distinct month_id from Sales_analysis
where year_id = 2004


-- what dealsize brings more revenue?

select dealsize, sum(sales) as Revenue
from Sales_analysis
group by dealsize
order by 2 desc

---what was the best month for sales in a specific year? how much was earned from that year?

select month_id , sum(sales) as Revenue, count(ordernumber) as Frequency
from Sales_analysis
where year_id =2004 --can be changed to see different years
group by month_id
order by 2 desc

----Novvember is the company's best sales month, what products are they selling  in November?


select month_id , productline, sum(sales) as Revenue, count(ordernumber) as Frequency
from Sales_analysis
where year_id =2004 and month_id =11 --can be changed to see different years
group by month_id,productline
order by 3 desc


----using RFM to determine who is our best customer 


Drop  table if exists #rfm

; with RFM as (
select 
		CUSTOMERNAME, 
		sum(sales) as MonetaryValue,
		avg(sales) as AvgMonetaryValue,
		count(ORDERNUMBER) as Frequency,
		max(ORDERDATE) as last_order_date,
		(select max(ORDERDATE) from Sales_analysis) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from Sales_analysis)) as Recency
	from Sales_analysis
	group by CUSTOMERNAME
	),
	rfm_calc as (


	select r.*,
	ntile(4) over(order by Recency desc) as rfm_recency,
	ntile(4) over (order by Frequency) as rfm_frequency,
	ntile(4) over (order by MonetaryValue) as rfm_monetary

	from rfm as r
	
	)
	select c.*, rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar)+ cast(rfm_frequency as varchar)+cast (rfm_monetary as varchar) as rfm_cell_string
	 into #rfm
	from rfm_calc as c 


	select customername, rfm_recency, rfm_frequency, rfm_monetary,
	
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven�t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

	from #rfm

	---- the above rfm analysis will help mostly when running different compaigns 


	---what products are oftne sold together?




	select ordernumber, stuff(
	(select ',' +productcode
	from Sales_analysis as p where ordernumber in (
	
	
	select ordernumber from (
	select ordernumber, count(*) as rn
	from Sales_analysis
	where status ='shipped'
	group by ordernumber) m 
	where rn= 2)

	and p.ordernumber = s.ordernumber

	for xml path ('')),1,1,'') as productcodes

	from Sales_analysis s
	order by 2 desc




	--- what city has the highest number of sales  in a specific country?

	select city, sum(sales) as Revenue
	from Sales_analysis
	where country ='UK'
	 group by city
	 order by 2 desc


	 ---what is the best product in United States?

	 select country, year_id, productline, sum(sales) as Revenue
	 from Sales_analysis
	 where country='USA'
	  group by country, year_id, productline
	  order by 4 desc

