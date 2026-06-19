/* =====================================================
   PRODUCT SEGMENTATION
===================================================== */

with product_segments as
(
select
    product_key,
    product_name,
    cost,

    case
        when cost between 0 and 500 then 'Low'
        when cost between 501 and 1000 then 'Mid'
        when cost between 1001 and 1500 then 'High'
        else 'Very High'
    end as cust_segment

from gold.dim_products
)

select
    cust_segment,
    count(product_key) as total_products

from product_segments

group by cust_segment
order by total_products desc;
