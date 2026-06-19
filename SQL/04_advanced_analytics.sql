/* =====================================================
   CUMULATIVE SALES ANALYSIS
===================================================== */

select
    order_date,
    sales,
    sum(sales) over (
        partition by year(order_date)
        order by order_date
    ) as running_total_sales,

    avg(avg_price) over (
        partition by year(order_date)
        order by order_date
    ) as avg_price

from
(
    select
        datetrunc(month,order_date) as order_date,
        sum(sales_amount) as sales,
        avg(price) as avg_price
    from gold.fact_sales
    where order_date is not null
    group by datetrunc(month,order_date)
)t;
