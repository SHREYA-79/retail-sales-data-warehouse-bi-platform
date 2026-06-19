/* =====================================================
   CUSTOMER INTELLIGENCE REPORTING VIEW
===================================================== */

CREATE VIEW gold.report_customers AS

-- =====================================================
-- 1. BASE QUERY
-- =====================================================

WITH base_query AS
(
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,

        c.customer_key,
        c.customer_number,
        c.first_name,
        c.last_name,

        CONCAT(c.first_name,' ',c.last_name) AS customer_name,

        c.birthdate,

        DATEDIFF(YEAR,c.birthdate,GETDATE()) AS age

    FROM gold.fact_sales f

    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key

    WHERE f.order_date IS NOT NULL
),

-- =====================================================
-- 2. CUSTOMER AGGREGATION
-- =====================================================

customer_aggregation AS
(
    SELECT

        b.customer_key,
        b.customer_number,
        b.customer_name,
        b.age,

        COUNT(DISTINCT b.order_number) AS total_orders,

        SUM(b.sales_amount) AS total_sales,

        SUM(b.quantity) AS total_qty,

        COUNT(DISTINCT b.product_key) AS total_products,

        MAX(b.order_date) AS last_order_date,

        DATEDIFF(
            MONTH,
            MIN(b.order_date),
            MAX(b.order_date)
        ) AS lifespan

    FROM base_query b

    GROUP BY
        b.customer_key,
        b.customer_number,
        b.customer_name,
        b.age
)

-- =====================================================
-- 3. CUSTOMER REPORT
-- =====================================================

SELECT

    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age Segmentation

    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and Above'
    END AS age_group,

    -- Revenue Segmentation

    CASE
        WHEN total_sales BETWEEN 0 AND 500 THEN 'Low'
        WHEN total_sales BETWEEN 501 AND 1000 THEN 'Mid'
        WHEN total_sales BETWEEN 1001 AND 1500 THEN 'High'
        ELSE 'Very High'
    END AS cust_segment,

    last_order_date,

    -- Customer Recency

    DATEDIFF(
        YEAR,
        last_order_date,
        GETDATE()
    ) AS recency,

    total_orders,
    total_sales,
    total_qty,
    total_products,
    lifespan,

    -- Average Order Value (AOV)

    CASE
        WHEN total_orders = 0 THEN 0
        ELSE CAST(total_sales AS FLOAT) / total_orders
    END AS avg_order_value,

    -- Average Monthly Spend

    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE CAST(total_sales AS FLOAT) / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;
