use DataWarehouseAnalytics;
go

/* =====================================================
   SALES TREND ANALYSIS
===================================================== */

select
    year(order_date) as year,
    month(order_date) as month,
    sum(sales_amount) as sales,
    count(distinct(customer_key)) as no_of_customers,
    sum(quantity) as total_quantities
from gold.fact_sales
where order_date is not null
group by month(order_date),year(order_date)
order by month(order_date),year(order_date);

select
    datetrunc(month,order_date) as order_month,
    sum(sales_amount) as sales,
    count(distinct(customer_key)) as no_of_customers,
    sum(quantity) as total_quantities
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
order by datetrunc(month,order_date);
